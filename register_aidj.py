import uuid
import os
import re

def make_xcode_uuid(seed):
    val = uuid.uuid5(uuid.NAMESPACE_DNS, seed).hex[:24].upper()
    return "04C7" + val[4:]

project_path = "/Users/mac/Desktop/Krank/Krank.xcodeproj/project.pbxproj"
filename = "AIDJEngine.swift"

if not os.path.exists(project_path):
    print("Project file not found!")
    exit(1)

with open(project_path, "r", encoding="utf-8") as f:
    content = f.read()

# Generate UUIDs
file_ref = make_xcode_uuid("fileref_" + filename)
build_file = make_xcode_uuid("buildfile_" + filename)

# Check if already added
if file_ref in content:
    print("AIDJEngine.swift already registered!")
    exit(0)

# 1. Insert Build File
build_file_section = "/* Begin PBXBuildFile section */"
if build_file_section in content:
    line = f"\t\t{build_file} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref} /* {filename} */; }};"
    content = content.replace(build_file_section + "\n", build_file_section + "\n" + line + "\n")

# 2. Insert File Reference
file_ref_section = "/* Begin PBXFileReference section */"
if file_ref_section in content:
    line = f"\t\t{file_ref} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = \"<group>\"; }};"
    content = content.replace(file_ref_section + "\n", file_ref_section + "\n" + line + "\n")

# 3. Add to Krank group children
group_pattern = r"(04C7491E2FEFF60C00B62262 /\* Krank \*/ = \{[^{]*children = \(\n)"
match = re.search(group_pattern, content)
if match:
    line = f"\t\t\t\t{file_ref} /* {filename} */,"
    content = content.replace(match.group(1), match.group(1) + line + "\n")

# 4. Add to Sources build phase files
sources_pattern = r"(04C749182FEFF60C00B62262 /\* Sources \*/ = \{[^{]*files = \(\n)"
match = re.search(sources_pattern, content)
if match:
    line = f"\t\t\t\t{build_file} /* {filename} in Sources */,"
    content = content.replace(match.group(1), match.group(1) + line + "\n")

with open(project_path, "w", encoding="utf-8") as f:
    f.write(content)

print("AIDJEngine.swift registered successfully in Xcode project!")
