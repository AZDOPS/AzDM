# Creating a new project.

Creating a new project is as easy as creating a folder.

In the `settings.json` file located in the root we configure the root folder, and whenever a new folder is created here, and as long as it is _not_ in the `excludeProjects` list of the `root/config.json` file a project will be created.

However, you may also want to set up some default values, or changed values. To do this you need to create a file named `projectName.json` in the project folder. For example, if the project name is "MiddleEarth", then the config file should be named "MiddleEarth.json".

> **Important:** Since you may run this on different operating systems, and some operating systems are case sensitive, please make sure the capitalization of the config file and the project folder are the same!

The `projectName.json` file layout is documented in the [jsonFileLayout](./jsonFileLayout.md) file, under projectName.json

> **Important:** In order for _any_ sub functionality such as repos or pipeline management to work you _need_ to set the `"core": {}` and `"project": {}` keys in the `projectName.json` file.
