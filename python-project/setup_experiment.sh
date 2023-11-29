#!/bin/bash
# Script to set up a Python project for experimentation


# Check installation prerequisites
command_exists() {
    type "$1" &> /dev/null ;
}

# Check if Poetry is installed
if ! command_exists poetry ; then
    echo "Poetry is not installed. Please install Poetry first."
    exit 1
fi

# Check if Git is installed
if ! command_exists git ; then
    echo "Git is not installed. Please install Git first."
    exit 1
fi


# Function to prompt for user input with default value
prompt_with_default() {
    read -p "$1 [$2]: " value
    echo "${value:-$2}"
}

# Prompt for project details
project_name=$(prompt_with_default "Enter project name (default: my-experiment)" "my-experiment")
project_path=$(prompt_with_default "Enter project path (default: ./)" ".")
project_description=$(prompt_with_default "Enter project description" "")
python_modules=$(prompt_with_default "Enter required Python modules (comma-separated no space)" "")

# Create project directory
project_dir="$project_path/$project_name"
mkdir -p "$project_dir"
cd "$project_dir"

# Initialize Git repository
git init

# Initialize Poetry environment
poetry init --name "$project_name" --description "$project_description" --no-interaction

# Create .gitignore file
curl https://www.toptal.com/developers/gitignore/api/macos,scala,python,intellij > .gitignore

# Create README.md file
cat <<EOF > README.md
# $project_name

$project_description
EOF

# Add and commit initial files
git add .
git commit -m "Initial commit"

git checkout -b develop

# Set up pre-commit
cat > .pre-commit-config.yaml <<EOF
# See https://pre-commit.com for more information
# See https://pre-commit.com/hooks.html for more hooks
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: check-merge-conflict
      - id: no-commit-to-branch
        args: [--branch, main]
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
        args: [--maxkb=5120]
  - repo: https://github.com/PyCQA/isort
    rev: 5.12.0
    hooks:
      - id: isort
        name: isort
  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.2.0
    hooks:
      - id: mypy
        additional_dependencies: ['types-all']
        args: [
          '--namespace-packages',
          '--explicit-package-bases'
        ]
  - repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
      - id: black
  - repo: https://github.com/hadialqattan/pycln
    rev: v2.1.3
    hooks:
      - id: pycln
        args: [--config=pyproject.toml]
  - repo: https://github.com/kynan/nbstripout
    rev: 0.6.1
    hooks:
        - id: nbstripout
EOF

# Install pre-commit
poetry add --dev pre-commit
poetry run pre-commit install

# Add and commit pre-commit configuration
git add .
git commit -m "set up pre-commit hooks"

# Install required Python modules
IFS=',' read -ra modules <<< "$python_modules"
for module in "${modules[@]}"; do
    poetry add "$module"
done

# Additional tools for code linting/formatting in notebooks
poetry add --dev jupyter-black

# Create directory structure for AI/ML experimentation
mkdir -p data models notebooks src scripts

# Add and commit changes
git add .
git commit -m "set up project structure"

echo "Project setup is complete."
