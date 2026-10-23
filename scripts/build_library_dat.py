#!/usr/bin/env python3
"""Compile Word Leap's editorial source into Cuentiva's CUENLIB v2 format.

Same 152-byte book records, offset tables, interned UTF-8 strings and 32-byte
sentence records as Cuentiva/scripts/build_library_dat.py. Unused learning
fields are empty/absent; the original editorial source remains reviewable.
"""
import argparse
import json
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[1]
EDITORIAL = ROOT / "CuentivaWordLeap/3 - App Resources/Editorial"
NONE = 0xffffffff


def read_books(stories_path, metadata_path):
    metadata = json.loads(metadata_path.read_text(encoding="utf-8")) if metadata_path else {}
    books = []
    for line in stories_path.read_text(encoding="utf-8").splitlines():
        if not line.strip() or line == "---":
            continue
        if line.startswith("@"):
            fields = line[1:].split("|", 4)
            if len(fields) != 5:
                raise ValueError("Invalid book header")
            identifier, author, title, english, summary = fields
            cover = metadata.get(identifier, {"level": "A1", "symbol": "book.closed", "palette": 0})
            books.append(dict(id=identifier, author=author, title=title, englishTitle=english,
                              summary=summary, sentences=[], **cover))
        else:
            if not books:
                raise ValueError("Passage before book header")
            pair = line.split("|", 1)
            spanish = pair[0].strip()
            if spanish:
                books[-1]["sentences"].append((spanish, pair[1].strip() if len(pair) > 1 else ""))
    if not 0 < len(books) <= 20_000 or len({b["id"] for b in books}) != len(books):
        raise ValueError("Empty catalogue or duplicate book IDs")
    for book in books:
        if not all(book[key] for key in ["id", "author", "title", "englishTitle", "sentences", "level", "symbol"]):
            raise ValueError("Missing required book content")
        if not isinstance(book["palette"], int) or not 0 <= book["palette"] < NONE:
            raise ValueError("Invalid cover palette")
        if len(book["sentences"]) > 10_000:
            raise ValueError("Book exceeds reader passage limit")
    return books


class Builder:
    def __init__(self, books):
        self.data = bytearray(b"CUENLIB\x00" + struct.pack("<II", 2, len(books)))
        self.data.extend(bytes(152 * len(books)))
        self.strings = {}
        for index, book in enumerate(books):
            fields = [book[k] for k in ["id", "title", "englishTitle", "author", "level", "symbol", "summary"]]
            fields += ["", None, None, None]  # license, authorID, format, scene
            record = b"".join(self.string(value) for value in fields)
            record += struct.pack("<II", book["palette"], 2)
            sentences = b""
            for number, (spanish, english) in enumerate(book["sentences"]):
                sentences += b"".join(self.string(value) for value in
                    [f'{book["id"]}-{number + 1}', spanish, english, None])
            record += struct.pack("<II", self.append(sentences), len(book["sentences"]))
            record += struct.pack("<II", len(self.data), 0)  # empty vocabulary
            record += struct.pack("<IIII", NONE, 0, NONE, 0)  # continuation, glossary
            record += struct.pack("<III", NONE, NONE, NONE)  # verb, location, personal author
            record += struct.pack("<III", NONE, 0, NONE)  # ending, editorial revision
            if len(record) != 152:
                raise ValueError("Invalid CUENLIB record size")
            self.data[16 + index * 152:16 + (index + 1) * 152] = record

    def append(self, data):
        offset = len(self.data)
        if offset + len(data) > 50_000_000:
            raise ValueError("Library exceeds reader limit")
        self.data.extend(data)
        return offset

    def string(self, value):
        if value is None:
            return struct.pack("<II", NONE, 0)
        if value not in self.strings:
            raw = value.encode("utf-8")
            self.strings[value] = (self.append(raw), len(raw))
        return struct.pack("<II", *self.strings[value])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Fail if the shipped DAT is stale")
    parser.add_argument("--stories", type=Path, default=EDITORIAL / "stories.txt")
    parser.add_argument("--metadata", type=Path, default=EDITORIAL / "metadata.json")
    parser.add_argument("--output", type=Path, default=EDITORIAL / "Library.dat")
    args = parser.parse_args()
    books = read_books(args.stories, args.metadata)
    data = bytes(Builder(books).data)
    if args.check:
        if not args.output.exists() or args.output.read_bytes() != data:
            raise SystemExit("Library.dat is stale; run scripts/build_library_dat.py")
    else:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_bytes(data)
    print(f"{args.output.name}: {len(books)} books, {len(data):,} bytes; {'verified' if args.check else 'compiled'}")


if __name__ == "__main__":
    main()
