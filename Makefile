FILENAME_zhwiki := zhwiki-20200501-all-titles-in-ns0
FILENAME_zhwikidict := zhwiktionary-20200520-all-titles-in-ns0

FILENAMES := $(FILENAME_zhwiki) $(FILENAME_zhwikidict)
ARCHIVES := $(addsuffix .gz, $(FILENAMES))

all: build

build: zhwiki.dict

download: $(ARCHIVES)

$(ARCHIVES):
	wget https://dumps.wikimedia.org/zhwiki/20200501/$(FILENAME_zhwiki).gz
	wget https://dumps.wikimedia.org/zhwiktionary/20200520/$(FILENAME_zhwikidict).gz

%: %.gz
	@gzip -k -d $<

web-slang.source:
	./zhwiki-web-slang.py > web-slang.source

zhwiki.source: $(FILENAMES) web-slang.source
	cat $(FILENAMES) web-slang.source > zhwiki.source

zhwiki.raw: zhwiki.source
	./convert.py zhwiki.source > zhwiki.raw

zhwiki.dict: zhwiki.raw
	libime_pinyindict zhwiki.raw zhwiki.dict

zhwiki.dict.yaml: zhwiki.raw
	sed 's/[ ][ ]*/\t/g' zhwiki.raw > zhwiki.rime.raw
	sed -i 's/\t0//g' zhwiki.rime.raw
	sed -i "s/'/ /g" zhwiki.rime.raw
	echo -e '---\nname: zhwiki\nversion: "0.1"\nsort: by_weight\n...\n' >> zhwiki.dict.yaml
	cat zhwiki.rime.raw >> zhwiki.dict.yaml

install: zhwiki.dict
	install -Dm644 zhwiki.dict -t $(DESTDIR)/usr/share/fcitx5/pinyin/dictionaries/

install_rime_dict: zhwiki.dict.yaml
	install -Dm644 zhwiki.dict.yaml -t $(DESTDIR)/usr/share/rime-data/

clean:
	rm -f $(FILENAMES) zhwiki.{source,raw,dict,dict.yaml} web-slang.source
