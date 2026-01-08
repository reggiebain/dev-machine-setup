# Helpful Commands/Tips

## Virtual Environments in UV
#### Generate a new virtual environment
```
uv venv my-project
uv activate my-project
uv pip install -r requirements.txt # install external dependencies from req file
uv pip install -e . # install current project as a package, adds symlink site-packages
```
#### Get VSCode to recognize the virtual environment
```
uv run python -m ipykernel install --user --name=my-project --display-name="Python (my-project)"
```