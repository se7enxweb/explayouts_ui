# Changelog

## 1.3.29

- Added: Chinese translations in Simplified (chi-CN) and Traditional (chi-TW) script; chi-HK falls back to chi-TW,
  from ekked's pull request #15.
- Added: Translations into seventeen languages from South Asia and Africa: Bengali, Urdu, Marathi, Telugu, Tamil,
  Gujarati, Kannada, Malayalam, Punjabi, Odia, Hausa, Amharic, Yoruba, Igbo, isiZulu, Somali and isiXhosa, from
  ekked's pull request #14.
- Added: Russian, Catalan, Serbian (Cyrillic and Latin), Bulgarian, Lithuanian, Portuguese (Portugal) and Afrikaans
  translations, from ekked's pull request #13.
- Added: Translations into eighteen more administration languages: Hindi, Korean, Bosnian, Lower Sorbian, Estonian,
  Irish, Icelandic, Greenlandic, Latvian, Hungarian, Maltese, Romanian, Albanian, Slovak, Slovenian, Japanese, Greek
  and Finnish, from ekked's pull request #12.
- Added: Swahili (Kenya) translation, from ekked's pull request #10.
- Added: A test that the admin4 Layouts pages load no jQuery, from ekked's pull request #9.
- Updated: A new class or siteaccess condition opens its list at once.
- Fixed: Translations that contradicted their language guide: wrong meanings, glossary breaches, forms of address,
  typos and English left in the text, from ekked's pull request #11.

## 1.3.27

- The layout preview renders in the administration's public siteaccess (`expLayoutsPreviewSiteAccess` of
  explayouts: `explayouts.ini [PreviewSettings] SiteAccess`, FrontSiteAccess, related siteaccesses, DefaultAccess),
  never in one with another database; without one it says so. With an explayouts that lacks the class the preview
  stays in DefaultAccess as before.
- The rule forms store every target and condition type the resolver knows (module targets of admin layouts,
  `ibexa_content_type`).
- The Layouts tab of the admin menu has an icon (admin4), the one of the dashboard's Layouts action.
- Arabic, Persian, Pashto and Kurdish (Kurmanji) translations; Spanish addresses the user with "tú" throughout;
  the ten translations of 1.3.26 carry the new preview message.
