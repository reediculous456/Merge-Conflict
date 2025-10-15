#!/bin/bash
set -e

REPO_NAME="Merge-Conflict"
WORKDIR="./$REPO_NAME"

cd "$WORKDIR"

# Init repo
echo "# Merge Conflict Practice" > README.md
git add README.md
git commit -m "Initial commit"
git branch -M main

############################
# 1. Simple Conflict (Web)
############################

git checkout -b simple-conflict
echo "Line from simple-conflict branch" >> README.md
git commit -am "Edit README in simple-conflict branch"

git checkout main
git checkout -b simple-conflict-main
echo "Line from main branch" >> README.md
git commit -am "Edit README in main branch"

# Merge to cause conflict
git checkout simple-conflict
git merge simple-conflict-main || echo "✅ Simple conflict created"

# Abort the merge to clean up for next conflict
git merge --abort

############################
# 2. Multi-line Conflict
############################

git checkout main
git reset --hard HEAD
echo -e "Line 1\nLine 2\nLine 3" > notes.txt
git add notes.txt
git commit -m "Add notes file"

git checkout -b multiline-branch
sed -i '' 's/Line 2/Line two changed in multiline-branch/' notes.txt
git commit -am "Change line 2 in multiline-branch"

git checkout main
git checkout -b multiline-main
sed -i '' 's/Line 2/Line two changed in multiline-main/' notes.txt
git commit -am "Change line 2 in multiline-main"

git checkout multiline-branch
git merge multiline-main || echo "✅ Multiline conflict created"

# Abort the merge to clean up for next conflict
git merge --abort

############################
# 3. Interdependent File Conflict
############################

git checkout main
git reset --hard HEAD
echo "Config=Prod" > config.env
echo "Using config.env" > main.py
git add config.env main.py
git commit -m "Add config and main.py"

git checkout -b config-branch
echo "Config=Staging" > config.env
sed -i '' 's/Using config.env/Using staging config/' main.py
git commit -am "Switch to staging"

git checkout main
git checkout -b feature-branch
echo "Config=Debug" > config.env
sed -i '' 's/Using config.env/Using debug config/' main.py
git commit -am "Switch to debug"

git checkout config-branch
git merge feature-branch || echo "✅ Interdependent conflict created"

# Abort the merge to clean up for next conflict
git merge --abort

echo -e "\n✅ All conflicts set up in: $WORKDIR"
echo "Branches with conflicts:"
echo "  - simple-conflict (README.md)"
echo "  - multiline-branch (notes.txt)"
echo "  - config-branch (config.env + main.py)"

############################
# 4. Complex Rename Conflict
############################

git checkout main
git reset --hard HEAD
echo "v1 content" > logic.txt
git add logic.txt
git commit -m "Add logic.txt"

# Branch A: rename + edit
git checkout -b rename-edit-branch
git mv logic.txt core_logic.py
echo "v2 from rename-edit-branch" > core_logic.py
git commit -am "Rename and update logic.txt to core_logic.py"

# Branch B: edit original
git checkout main
git checkout -b edit-original-branch
echo "v2 from edit-original-branch" > logic.txt
git commit -am "Update logic.txt in edit-original-branch"

# Merge
git checkout rename-edit-branch
git merge edit-original-branch || echo "✅ Rename/content conflict created"
git merge --abort

############################
# 5. Directory Restructure + Edit Conflict
############################

git checkout main
git reset --hard HEAD
echo "settings = default" > settings.py
git add settings.py
git commit -m "Add settings.py"

# Branch A: move + edit
git checkout -b move-edit-branch
mkdir config
git mv settings.py config/settings.py
echo "settings = moved and modified in move-edit-branch" > config/settings.py
git add .
git commit -m "Move and edit settings.py"

# Branch B: edit original location
git checkout main
git checkout -b edit-settings-branch
echo "settings = modified in edit-settings-branch" > settings.py
git commit -am "Edit settings.py in place"

# Merge
git checkout move-edit-branch
git merge edit-settings-branch || echo "✅ Move + edit conflict created"
git merge --abort

############################
# 6. Cross-File + In-File Conflict
############################

git checkout main
git reset --hard HEAD
echo -e "def greet(name):\n    return f\"Hello, {name}!\"" > utils.py
echo -e "from utils import greet\nprint(greet('Wes'))" > app.py
git add utils.py app.py
git commit -m "Initial greet function and usage"

# Branch A: Change function signature and body
git checkout -b update-signature
echo -e "def greet(name, title):\n    return f\"Hello, {title} {name}!\"" > utils.py
git commit -am "Update greet signature and message"

# Branch B: Change the same function line differently
git checkout main
git checkout -b modify-same-line
echo -e "def greet(name):\n    return f\"Hi there, {name}!\"" > utils.py
git commit -am "Change greeting wording"

# Merge to create conflict
git checkout update-signature
git merge modify-same-line || echo "✅ Cross-file & in-file conflict created"
git merge --abort

############################
# 7. Reordering + Logical Conflict
############################

git checkout main
git reset --hard HEAD
echo -e "timeout=30\nretry=3\ndebug=true" > config.ini
git add config.ini
git commit -m "Initial config.ini"

# Branch A: Reorder and change value
git checkout -b reorder-config
echo -e "debug=false\ntimeout=60\nretry=3" > config.ini
git commit -am "Reorder and change timeout"

# Branch B: Change retry and add new setting
git checkout main
git checkout -b edit-config
echo -e "timeout=30\nretry=5\ndebug=true\nauto_save=true" > config.ini
git commit -am "Update retry and add auto_save"

git checkout reorder-config
git merge edit-config || echo "✅ Reorder + logic conflict created"
git merge --abort

############################
# 8. Delete vs Edit Conflict
############################

git checkout main
git reset --hard HEAD
echo -e "# Temporary script\nprint('Temp')" > temp.py
git add temp.py
git commit -m "Add temp.py"

# Branch A: Delete the file
git checkout -b delete-temp
git rm temp.py
git commit -m "Delete temp.py"

# Branch B: Modify the file
git checkout main
git checkout -b edit-temp
echo -e "# Temporary script updated\nprint('Updated Temp')" > temp.py
git commit -am "Edit temp.py"

git checkout delete-temp
git merge edit-temp || echo "✅ Delete vs edit conflict created"
git merge --abort
