# xml-to-localizable
Convert Android XML strings file to iOS localizable string file

This script can be called from an Xcode 'Run Script' build phase at the beginning of the build process, like this:

    ${PROJECT_DIR}/xml_to_localizable.rb ${PROJECT_NAME}

This script should be placed in the same directory as your .xcodeproj project.


############################################################################

May you need to run the following commands to give access permission to the script file:

```
gem install iconv
```

```
chmod u+x xml_to_localizable.rb 
```
