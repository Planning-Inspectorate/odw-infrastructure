from dotenv import load_dotenv
import os


load_dotenv(verbose=True, override=True)

"""
    Extract environment variables
"""

TEST_CONFIG = {
    k: os.environ.get(k, None)
    for k in [
        "ENV",
        "DATA_LAKE_STORAGE",
        "SUBSCRIPTION_ID",
        "PURVIEW_ID",
        "PURVIEW_EVENT_HUB_ID",
        "PURVIEW_STORAGE_ID",
        "ODT_SUBSCRIPTION_ID"
    ]
}
