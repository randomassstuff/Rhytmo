## Creating the JSON File
First, you need to create a file in `assets/languages/` called `[language-code].json`. <br>
The name doesn't really matter, so you can call it whatever you want.

For its data, copy [this](https://raw.githubusercontent.com/Joalor64GH/Rhythmo-SC/main/assets/languages/en.json), and edit it with your translations.

## Loading your Language
Now, you need to edit the main text file, `assets/languages/languagesList.txt`, which just contains the data for your language(s). <br>
To add your language into `languagesList.txt`, use this format:
```
Name (Country/Tag):save-tag
```

So, for example, if you wanted to add German, it would look like:
```
Deutsch (Deutschland):de
```

## Custom Font Support
If you want to add a custom font to your language, add this field anywhere in your `.json`:
```json
{
    "customFont": "font"
}
```

Also, make sure that your font actually exists before doing so.

You can also have your font be shown in the language selection menu. <br>
Wherever your languages is in `languagesList.txt`, add this extra field:
```
Deutsch (Deutschland):de:germanFont
```

## Localization Functions
Like most functions, these can be accessed through [scripting](https://github.com/Joalor64GH/Rhythmo-SC/wiki/Scripting).

### Switching to Another Language
HScript:
```hx
Localization.switchLanguage('language-tag');
```

Lua:
```lua
switchLanguage('language-tag');
```

If that language is already selected, the change will not happen.

### Retrieving a Key
HScript:
```hx
Localization.get('key', 'language-tag');
```

Lua:
```lua
getLangKey('key', 'language-tag');
```

If the second parameter is empty, defaults to current language.

For further documentation, check out [`SimpleLocalization`](https://github.com/Joalor64GH/SimpleLocalization).