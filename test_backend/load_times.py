import sys
import time
import tempfile
import shutil
from statistics import mean
from collections import defaultdict
from urllib.parse import urlparse, urlunparse, parse_qs, urlencode

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait

def append_cache_buster(src: str) -> str:
    """Append a cache-busting query parameter to the image URL."""
    parsed = list(urlparse(src))
    qs = parse_qs(parsed[4])
    qs["cb"] = int(time.time() * 1000)
    parsed[4] = urlencode(qs, doseq=True)
    return urlunparse(parsed)

def measure_image_load_times(driver, url):
    driver.execute_cdp_cmd("Network.enable", {})
    driver.execute_cdp_cmd("Network.clearBrowserCache", {})
    driver.execute_cdp_cmd("Network.setCacheDisabled", {"cacheDisabled": True})

    driver.get(url)

    WebDriverWait(driver, 30).until(
        lambda d: d.execute_script("return document.readyState") == "complete"
    )
    time.sleep(2)

    images = driver.find_elements(By.TAG_NAME, "img")
    load_times = []

    for img in images:
        src = img.get_attribute("src")
        if not src:
            continue

        busted_src = append_cache_buster(src)

        try:
            driver.execute_script("arguments[0].src = arguments[1];", img, busted_src)
        except Exception:
            continue

        start = time.time()
        try:
            WebDriverWait(driver, 10).until(lambda d: d.execute_script("""
                const img = arguments[0];
                return img.complete && img.naturalWidth > 0;
            """, img))
            elapsed = time.time() - start
            load_times.append((src, elapsed, busted_src))
        except:
            continue

    # Get performance entries (after page and images load)
    perf_data = driver.execute_script("return performance.getEntriesByType('resource');")
    image_sizes = {}
    for entry in perf_data:
        if entry.get("initiatorType") == "img" and entry.get("name"):
            name = entry["name"]
            size = entry.get("transferSize")
            if size:
                image_sizes[name] = size

    # Attach sizes to load_times
    result = []
    for orig_src, elapsed, busted_src in load_times:
        size = image_sizes.get(busted_src)
        result.append((orig_src, elapsed, size))

    return result

def main():
    if len(sys.argv) != 3:
        print("Usage: python average_image_load_times.py <URL> <NUM_RUNS>")
        sys.exit(1)

    url = sys.argv[1]
    try:
        num_runs = int(sys.argv[2])
        if num_runs <= 0:
            raise ValueError
    except ValueError:
        print("NUM_RUNS must be a natural number (positive integer).")
        sys.exit(1)

    print(f"Pinging {url} {num_runs} times with cache-busting and size tracking...\n")

    all_image_times = []
    per_image_stats = defaultdict(list)

    for run in range(1, num_runs + 1):
        print(f"Run {run}/{num_runs}...")

        user_data_dir = tempfile.mkdtemp()

        options = Options()
        options.add_argument("--headless")
        options.add_argument("--incognito")
        options.add_argument("--disable-application-cache")
        options.add_argument("--disable-cache")
        options.add_argument("--log-level=3")
        options.add_argument(f"--user-data-dir={user_data_dir}")

        driver = webdriver.Chrome(options=options)

        try:
            image_times = measure_image_load_times(driver, url)
            for src, elapsed, size in image_times:
                all_image_times.append(elapsed)
                per_image_stats[src].append((elapsed, size))
            print(f"  Loaded {len(image_times)} images.")
        except Exception as e:
            print(f"  Run failed: {e}")
        finally:
            driver.quit()
            shutil.rmtree(user_data_dir)
            time.sleep(1)

    if all_image_times:
        avg_time = mean(all_image_times)
        print(f"\n✅ Completed {num_runs} runs.")
        print(f"📷 Total images loaded: {len(all_image_times)}")
        print(f"⏱️ Average image load time: {avg_time:.4f} seconds")

        print("\n📊 Per-Image Breakdown:")
        for i, (src, records) in enumerate(per_image_stats.items(), 1):
            times = [r[0] for r in records]
            sizes = [r[1] for r in records if r[1] is not None]
            avg_time = mean(times)
            avg_size = f"{mean(sizes) / (1024 * 1024):.2f} MB" if sizes else "Unknown"
            print(f"[{i}] {src[:80]}... -> loaded {len(times)} times, avg: {avg_time:.4f}s, size: {avg_size}")
    else:
        print("\n⚠️ No images loaded successfully across all runs.")


if __name__ == "__main__":
    main()
