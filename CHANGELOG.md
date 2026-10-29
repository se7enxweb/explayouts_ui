# Changelog

## 1.3.32 (2026-10-29)

- Updated: One copyright notice, Exponential Foundation and 7x.

## 1.3.31 (2026-10-29)

- Updated: The admin stylesheets use the shared admin tokens for weights, durations, radii, table headers and muted text, with the old values as fallbacks where a design has no tokens.

## 1.3.30 (2026-10-28)

- Added: Translations into 59 more languages: aka-GH, arc-IQ, asm-IN, aze-AZ, bel-BY, bho-IN, bod-CN, ceb-PH, che-RU,
  ckb-IQ, cym-GB, eng-AU, eus-ES, fil-PH, ful-SN, gla-GB, glg-ES, haw-US, huy-IL, hye-AM, ind-ID, jav-ID, kat-GE,
  kaz-KZ, khm-KH, kik-KE, kin-RW, kir-KG, lao-LA, lin-CD, ltz-LU, lug-UG, mai-IN, mkd-MK, mlg-MG, mon-MN, mri-NZ,
  msa-MY, mya-MM, nep-NP, orm-ET, pcm-NG, pnb-PK, run-BI, sin-LK, sna-ZW, snd-PK, sun-ID, syr-IQ, tat-RU, tgk-TJ,
  tha-TH, tir-ET, tuk-TM, uig-CN, uzb-UZ, vie-VN, wol-SN and yid-US.
- Updated: The ara-SA, bos-BA, dsb-DE, ell-GR, est-EE, fas-IR, fin-FI, fre-FR, gle-IE, hin-IN, hun-HU, isl-IS, jpn-JP,
  kal-GL, kor-KR, kur-TR, lav-LV, mlt-MT, pus-AF, ron-RO, slk-SK, slv-SI, sqi-AL, swa-KE and ukr-UA translations are
  complete.

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
