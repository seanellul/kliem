#!/usr/bin/env python3

import re

def remove_unknown_words(file_path):
    print(f"Processing {file_path}...")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Count original entries
    original_unknown_count = content.count("'translation': 'Unknown'")
    print(f"Found {original_unknown_count} entries with 'translation': 'Unknown'")
    
    # Pattern to match complete entries with only 'translation': 'Unknown'
    pattern = r"\s*'([^']+)':\s*\{\s*'translation':\s*'Unknown',?\s*\},?\n?"
    
    # Find all matches and extract word names
    matches = re.findall(pattern, content)
    print(f"Words to be removed: {matches[:10]}{'...' if len(matches) > 10 else ''}")
    
    # Remove the entries
    new_content = re.sub(pattern, '', content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    # Verify
    with open(file_path, 'r', encoding='utf-8') as f:
        new_content = f.read()
    
    remaining_unknown = new_content.count("'translation': 'Unknown'")
    print(f"Removed {len(matches)} entries")
    print(f"Remaining 'translation': 'Unknown' entries: {remaining_unknown}")
    
    return len(matches), matches

if __name__ == "__main__":
    files_to_clean = [
        "/Users/seanellul/Code/Flutter/Maltese Wordle Game/FLUTTER-BUILD/werdil/lib/utils/word_translations.dart",
        "/Users/seanellul/Code/Flutter/Maltese Wordle Game/FLUTTER-BUILD/werdil/lib/utils/word_translations_complete.dart"
    ]
    
    total_removed = 0
    all_removed_words = []
    
    for file_path in files_to_clean:
        try:
            removed, words = remove_unknown_words(file_path)
            total_removed += removed
            all_removed_words.extend(words)
        except Exception as e:
            print(f"Error processing {file_path}: {e}")
    
    print(f"\n=== SUMMARY ===")
    print(f"Total entries removed: {total_removed}")
    print(f"Files processed successfully!")