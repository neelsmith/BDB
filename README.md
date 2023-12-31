# BDB

Digital version of Brown-Driver-Briggs Lexicon.


## Source

Data in this repository are dervived from the text available from [this github repository](https://github.com/eliranwong/unabridged-BDB-Hebrew-lexicon/tree/master), in the file `unabridged-BDB-Hebrew-lexicon.csv.zip`.  That zip file contains a single CSV file with a header and 1022 records.  I have extracted from that CSV file three columns yielding a unique BDB identifier, a cross-reference to Strong, and an article formatted with the unique XML vocabulary of the source document.  The result is a single delimited-text file in this repository, `src/lex-wellformed.cex`.  Julia scripts in the `scripts` directory create a derivative version  from it.  The result is a delimited-text file with the article in Markdown rather XML.

Elements removed by regular expression from source XML:

- `entry`
- `div`, `p` structures replaced with terminating pilcrow
- empty `placeholder`

### XML usage

The following XML elements the source document are taken into consideration in formatting Markdown:


- `bdbheb`. Marks term in Biblical Hebrew.
- `highlight` -> `*`
- `sup` rm
- `b` -> `**`
- `highlightword` -> `**`
- `ref` -> ?
- `bdbarc`. Marks term in Biblical Aramaic.
- `checkingNeeded` Removed in md.
- `transliteration`  -> `*`
- `grk` rm
- `sub`
- `wrongReferenceRemoved`. Removed in md.
- `big`. Font designation.  Removed in Markdown.
- `u` rm