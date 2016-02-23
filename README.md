# MarkdownのテーブルをYAMLに変換する。

Pandoc と Perlを使って、Markdownの表をYAMLに変換します。

# 必要なPerlモジュール

	JSON::XS
	YAML::XS

# PerlモジュールとPandocのインストール
cpanm, brew設定済みのOSXの例

	$ cpanm JSON::XS YAML::XS
	$ brew install pandoc

# サンプルデータ

A列A    | A列B    | A列C
--------|---------|----------
A行1列A | A行1列B | A行1列C
A行2列A | A行2列B | A行2列C
A行3列A | A行3列B | A行3列C
A行4列A | A行4列B | A行4列C
A行5列A | A行5列B | A行5列C

B列A    | B列B    | B列C
--------|---------|----------
B行1列A | B行1列B | B行1列C
B行2列A | B行2列B | B行2列C
B行3列A | B行3列B | B行3列C
B行4列A | B行4列B | B行4列C
B行5列A | B行5列B | B行5列C

# 使用例

	$ cat README.md | pandoc -t markdown -t json | ./mdtable2yaml.pl

# 処理結果

	---
	- fields:
	  - A列A
	  - A列B
	  - A列C
	  rows:
	  - - A行1列A
	    - A行1列B
	    - A行1列C
	  - - A行2列A
	    - A行2列B
	    - A行2列C
	  - - A行3列A
	    - A行3列B
	    - A行3列C
	  - - A行4列A
	    - A行4列B
	    - A行4列C
	  - - A行5列A
	    - A行5列B
	    - A行5列C
	- fields:
	  - B列A
	  - B列B
	  - B列C
	  rows:
	  - - B行1列A
	    - B行1列B
	    - B行1列C
	  - - B行2列A
	    - B行2列B
	    - B行2列C
	  - - B行3列A
	    - B行3列B
	    - B行3列C
	  - - B行4列A
	    - B行4列B
	    - B行4列C
	  - - B行5列A
	    - B行5列B
	    - B行5列C
	
