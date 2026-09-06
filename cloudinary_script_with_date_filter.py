import cloudinary
import cloudinary.api
from pathlib import Path
import re
import os
from dotenv import load_dotenv

load_dotenv()


# ============================================================
#                 CLOUDINARY SETTINGS
# ============================================================
CLOUD_NAME = os.getenv("CLOUD_NAME")
API_KEY = os.getenv("API_KEY")
API_SECRET = os.getenv("API_SECRET")


# ============================================================
#                 SONG SETTINGS
# ============================================================

# Dart ID कहाँबाट सुरु गर्ने?
START_ID = 126

# तपाईंको Dart मा यही folder राखिनेछ
DART_FOLDER = "Pop"


# यदि Cloudinary मा songs कुनै एउटै वास्तविक folder भित्र छन् भने
# यहाँ folder name राख्नुहोस्।
#
# Example:
# ASSET_FOLDER = "songs"
#
# सबै ठाउँका MP3 खोज्ने हो भने खाली राख्नुहोस्:
ASSET_FOLDER = "pop"


# ============================================================
#                 DATE FILTER
# ============================================================

# खाली राख्दा date filter हुँदैन।
#
# एउटै दिनका songs मात्र:
# FROM_DATE = "2026-09-06"
# TO_DATE = "2026-09-06"
#
# Date range:
# FROM_DATE = "2026-09-01"
# TO_DATE = "2026-09-06"
#
# September 1 पछि upload भएका:
# FROM_DATE = "2026-09-01"
# TO_DATE = ""
#
# September 6 सम्म upload भएका:
# FROM_DATE = ""
# TO_DATE = "2026-09-06"
#
# सबै songs:
# FROM_DATE = ""
# TO_DATE = ""

FROM_DATE = ""
TO_DATE = ""


# Output file
OUTPUT_FILE = "pop_songs.dart"


# ============================================================
#                 CLOUDINARY CONFIG
# ============================================================

cloudinary.config(
    cloud_name=CLOUD_NAME,
    api_key=API_KEY,
    api_secret=API_SECRET,
    secure=True,
)


# ============================================================
#                 TEXT HELPERS
# ============================================================

def clean_text(text):

    if not text:
        return "Unknown"

    text = str(text).strip()

    text = text.replace("_", " ")

    text = re.sub(r"\s+", " ", text)

    return text.strip()


def dart_escape(text):

    if text is None:
        return ""

    text = str(text)

    text = text.replace("\\", "\\\\")

    text = text.replace("'", "\\'")

    return text


# ============================================================
#                 TITLE EXTRACTION
# ============================================================

def get_title(asset):

    # --------------------------------------------------------
    # 1. Context title
    # --------------------------------------------------------

    context = asset.get("context")

    if isinstance(context, dict):

        for key in [
            "title",
            "Title",
            "song_title",
            "songTitle",
            "name",
        ]:

            if context.get(key):

                return clean_text(
                    context[key]
                )


    # --------------------------------------------------------
    # 2. Structured metadata title
    # --------------------------------------------------------

    metadata = asset.get("metadata")

    if isinstance(metadata, dict):

        for key in [
            "title",
            "Title",
            "song_title",
            "songTitle",
            "name",
        ]:

            if metadata.get(key):

                return clean_text(
                    metadata[key]
                )


    # --------------------------------------------------------
    # 3. Display name
    # --------------------------------------------------------

    if asset.get("display_name"):

        return clean_text(
            asset["display_name"]
        )


    # --------------------------------------------------------
    # 4. Filename
    # --------------------------------------------------------

    if asset.get("filename"):

        filename = asset["filename"]

        filename = Path(
            filename
        ).stem

        return clean_text(
            filename
        )


    # --------------------------------------------------------
    # 5. Public ID
    # --------------------------------------------------------

    if asset.get("public_id"):

        public_id = asset["public_id"]

        public_id = public_id.split("/")[-1]

        return clean_text(
            public_id
        )


    return "Unknown"


# ============================================================
#                 ARTIST EXTRACTION
# ============================================================

def get_artist(asset):

    # --------------------------------------------------------
    # Context
    # --------------------------------------------------------

    context = asset.get("context")

    if isinstance(context, dict):

        for key in [
            "artist",
            "Artist",
            "singer",
            "Singer",
            "artist_name",
            "artistName",
        ]:

            if context.get(key):

                return clean_text(
                    context[key]
                )


    # --------------------------------------------------------
    # Structured metadata
    # --------------------------------------------------------

    metadata = asset.get("metadata")

    if isinstance(metadata, dict):

        for key in [
            "artist",
            "Artist",
            "singer",
            "Singer",
            "artist_name",
            "artistName",
        ]:

            if metadata.get(key):

                return clean_text(
                    metadata[key]
                )


    return "Unknown"


# ============================================================
#                 SEARCH CLOUDINARY
# ============================================================

def get_all_mp3():

    print()
    print("=" * 65)
    print("        CLOUDINARY SONG EXPORTER")
    print("=" * 65)
    print()

    print("Searching Cloudinary...")
    print()

    # Base query
    expression = (
        "resource_type:video AND "
        "format:mp3"
    )

    # Optional Cloudinary asset folder
    if ASSET_FOLDER:

        expression += (
            f' AND asset_folder:"{ASSET_FOLDER}"'
        )


    # ========================================================
    # DATE FILTER
    # ========================================================

    if FROM_DATE and TO_DATE:

        expression += (
            f' AND created_at:[{FROM_DATE}T00:00:00Z '
            f'TO {TO_DATE}T23:59:59Z]'
        )

    elif FROM_DATE:

        expression += (
            f' AND created_at:[{FROM_DATE}T00:00:00Z TO *]'
        )

    elif TO_DATE:

        expression += (
            f' AND created_at:[* TO {TO_DATE}T23:59:59Z]'
        )


    print("Search:")
    print(expression)
    print()

    all_assets = []

    next_cursor = None

    while True:

        search = (
            cloudinary.Search()
            .expression(expression)
            .max_results(500)
        )

        if next_cursor:

            search = search.next_cursor(
                next_cursor
            )

        result = search.execute()

        resources = result.get(
            "resources",
            []
        )

        all_assets.extend(
            resources
        )

        print(
            f"Found {len(resources)} "
            f"(total = {len(all_assets)})"
        )

        next_cursor = result.get(
            "next_cursor"
        )

        if not next_cursor:

            break

    return all_assets


# ============================================================
#                 SORT SONGS
# ============================================================

def sort_songs(assets):

    # Creation date अनुसार stable order
    assets.sort(
        key=lambda x: (
            x.get(
                "created_at",
                ""
            ),
            x.get(
                "public_id",
                ""
            ),
        )
    )

    return assets


# ============================================================
#                 REMOVE DUPLICATES
# ============================================================

def remove_duplicates(assets):

    result = []

    seen = set()

    for asset in assets:

        url = asset.get(
            "secure_url"
        )

        public_id = asset.get(
            "public_id"
        )

        unique_key = (
            url
            or public_id
        )

        if not unique_key:

            continue

        if unique_key in seen:

            continue

        seen.add(
            unique_key
        )

        result.append(
            asset
        )

    return result


# ============================================================
#                 GENERATE DART
# ============================================================

def generate_dart(assets):

    lines = []

    lines.append(
        "// ====================================================="
    )

    lines.append(
        "// AUTO GENERATED FROM CLOUDINARY"
    )

    lines.append(
        "// ====================================================="
    )

    lines.append("")

    lines.append(
        "final List<Song> songs = ["
    )

    lines.append("")

    current_id = START_ID

    for asset in assets:

        title = get_title(
            asset
        )

        artist = get_artist(
            asset
        )

        audio_url = asset.get(
            "secure_url"
        )

        if not audio_url:

            public_id = asset.get(
                "public_id"
            )

            if public_id:

                audio_url = (
                    f"https://res.cloudinary.com/"
                    f"{CLOUD_NAME}/video/upload/"
                    f"{public_id}.mp3"
                )

            else:

                audio_url = ""


        # Escape Dart strings

        title = dart_escape(
            title
        )

        artist = dart_escape(
            artist
        )

        audio_url = dart_escape(
            audio_url
        )


        # ----------------------------------------------------
        # Song object
        # ----------------------------------------------------

        lines.append(
            "  Song("
        )

        lines.append(
            f"    id: '{current_id}',"
        )

        lines.append(
            f"    title: '{title}',"
        )

        lines.append(
            f"    artist: '{artist}',"
        )

        lines.append(
            "    audioUrl:"
        )

        lines.append(
            f"        '{audio_url}',"
        )

        lines.append(
            f"    folders: ['{DART_FOLDER}'],"
        )

        lines.append(
            "  ),"
        )

        lines.append("")

        current_id += 1


    lines.append(
        "];"
    )

    lines.append("")

    return "\n".join(
        lines
    )


# ============================================================
#                 MAIN
# ============================================================

def main():

    try:

        assets = get_all_mp3()

    except Exception as error:

        print()
        print("=" * 65)
        print("ERROR")
        print("=" * 65)
        print()

        print(error)

        print()
        print(
            "Check your Cloudinary Cloud Name, "
            "API Key and API Secret."
        )

        print()

        input(
            "Press Enter to exit..."
        )

        return


    # --------------------------------------------------------
    # No songs
    # --------------------------------------------------------

    if not assets:

        print()
        print(
            "No MP3 files found."
        )

        print()
        print(
            "If your songs are inside a Cloudinary folder, "
            "set ASSET_FOLDER at the top of this file."
        )

        print()

        input(
            "Press Enter to exit..."
        )

        return


    # --------------------------------------------------------
    # Sort
    # --------------------------------------------------------

    assets = sort_songs(
        assets
    )


    # --------------------------------------------------------
    # Remove duplicates
    # --------------------------------------------------------

    assets = remove_duplicates(
        assets
    )


    # --------------------------------------------------------
    # Generate
    # --------------------------------------------------------

    dart_code = generate_dart(
        assets
    )


    # --------------------------------------------------------
    # Save
    # --------------------------------------------------------

    Path(
        OUTPUT_FILE
    ).write_text(
        dart_code,
        encoding="utf-8"
    )


    # --------------------------------------------------------
    # Summary
    # --------------------------------------------------------

    first_id = START_ID

    last_id = (
        START_ID
        + len(assets)
        - 1
    )


    print()
    print("=" * 65)
    print("                    DONE!")
    print("=" * 65)
    print()

    print(
        f"Songs found : {len(assets)}"
    )

    print(
        f"ID range    : {first_id} -> {last_id}"
    )

    print(
        f"Output file : {OUTPUT_FILE}"
    )

    print()

    print("First 10 songs:")
    print("-" * 65)

    for index, asset in enumerate(
        assets[:10],
        start=START_ID
    ):

        print(
            f"{index}. "
            f"{get_title(asset)}"
            f" — "
            f"{get_artist(asset)}"
        )

    print()

    print(
        "songs.dart has been generated successfully."
    )

    print()

    input(
        "Press Enter to exit..."
    )


# ============================================================
# RUN
# ============================================================

if __name__ == "__main__":

    main()