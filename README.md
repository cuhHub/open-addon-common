# cuhHub - Common Addon Code

## 📚 Overview
A bunch of classes, services, libraries, etc., used throughout cuhHub addons.

These are used in cuhHub addons via [cuhkit](https://github.com/cuhHub/cuhkit)'s git imports feature.

Most of the code in this repo depends on [Noir](https://github.com/cuhHub/Noir).

## ⚠️ Warnings
- Some services, enums, libs, etc., depend on each other. This repo was created far after the code was written, and was directly extracted from cuhHub addons. As a result, things aren't too clean and dependencies will have to be manually determined.
- Some code may depend on code from a private version of this repo.

## ❔ Usage
- Create a cuhkit addon project.
- Create a `.build.json` file in the src of your project.
- Add git imports to the `.build.json` for all folders in `src` (or pick out the files you need).
```json
{
    ...,

    "import_git" : [
        {
            "repo_url" : "https://github.com/cuhHub/open-addon-common",
            "branch" : "main",
            "path" : "src/libraries",
            "destination" : "libraries"
        },

        {
            "repo_url" : "https://github.com/cuhHub/open-addon-common",
            "branch" : "main",
            "path" : "src/services",
            "destination" : "services"
        },

        ... // etc
    ],

    ...
}
```
- Copy over `src/config.lua` manually, and modify as needed.
- Build your project with `cuhkit build`. Everything should be imported automatically, and updated with every build.

## ✨ Credit
- [Cuh4](https://github.com/Cuh4)