# See the README for installation instructions.

# Utilities
JS_COMPILER = ./node_modules/uglify-js/bin/uglifyjs -c -m -
COFFEESCRIPT_COMPILER = ./node_modules/coffee-script/bin/coffee
MARKDOWN_COMPILER = bin/kramdown

# Turns out that just pointing Vows at a directory doesn't work, and its test matcher matches on
# the test's title, not its pathname. So we need to find everything in test/vows first.
VOWS = find test/vows -type f -name '*.js' -o -name '*.coffee' ! -name '.*' | xargs ./node_modules/.bin/vows --isolate --dot-matrix
MOCHA = find test/mocha -type f -name '*.js' -o -name '*.coffee' ! -name '.*' | xargs node_modules/.bin/mocha --reporter dot

SASS_COMPILER = bin/sass -I src --require ./src/helpers/sass/lab_fontface.rb
R_OPTIMIZER = ./node_modules/.bin/r.js
GENERATE_INTERACTIVE_INDEX = ruby src/helpers/process-interactives.rb

LAB_SRC_FILES := $(shell find src/lab -type f ! -name '.*' -print)
MD2D_SRC_FILES := $(shell find src/lab/md2d -type f ! -name '.*' -print)
GRAPHER_SRC_FILES := $(shell find src/lab/grapher -type f ! -name '.*' -print)
IMPORT_EXPORT_SRC_FILES := $(shell find src/lab/import-export -type f ! -name '.*' -print)
IFRAME_PHONE_SRC_FILES := $(shell find src/lab/iframe-phone -type f ! -name '.*' -print)
SENSOR_APPLET_SRC_FILES := $(shell find src/lab/sensor-applet -type f ! -name '.*' -print)

COMMON_SRC_FILES := $(shell find src/lab/common -type f ! -name '.*' -print)

# files generated by script during build process so cannot be listed using shell find.
COMMON_SRC_FILES += src/lab/lab.version.js
COMMON_SRC_FILES += src/lab/lab.config.js

FONT_FOLDERS := $(shell find vendor/fonts -mindepth 1 -maxdepth 1)

SASS_LAB_LIBRARY_FILES := $(shell find src/sass/lab -name '*.sass')

# targets

INTERACTIVE_FILES := $(shell find src/models src/interactives -name '*.json' -exec echo {} \; | sed s'/src\/\(.*\)/public\/\1/' )
vpath %.json src

HAML_FILES := $(shell find src -name '*.haml' -exec echo {} \; | sed s'/src\/\(.*\)\.haml/public\/\1/' )
vpath %.haml src

SASS_FILES := $(shell find src -name '*.sass' -and -not -path "src/sass/*" -exec echo {} \; | sed s'/src\/\(.*\)\.sass/public\/\1.css/' )
SASS_FILES += $(shell find src -name '*.scss' -and -not -path "src/sass/*" -exec echo {} \; | sed s'/src\/\(.*\)\.scss/public\/\1.css/' )
vpath %.sass src
vpath %.scss src

COFFEESCRIPT_FILES := $(shell find src/doc -name '*.coffee' -exec echo {} \; | sed s'/src\/\(.*\)\.coffee/public\/\1.js/' )
COFFEESCRIPT_FILES += $(shell find src/examples -name '*.coffee' -exec echo {} \; | sed s'/src\/\(.*\)\.coffee/public\/\1.js/' )
COFFEESCRIPT_FILES += $(shell find src/experiments -name '*.coffee' -exec echo {} \; | sed s'/src\/\(.*\)\.coffee/public\/\1.js/' )
vpath %.coffee src

MARKDOWN_FILES := $(shell find src -name '*.md' -and -not -path "src/sass/*" -exec echo {} \; | grep -v vendor | sed s'/src\/\(.*\)\.md/public\/\1.html/' )
vpath %.md src

LAB_JS_FILES = \
	public/lab/lab.js \
	public/lab/lab.grapher.js \
	public/lab/lab.import-export.js \
	public/lab/lab.iframe-phone.js \
	public/lab/lab.sensor-applet.js

# default target executed when running make
.PHONY: all
all: \
	vendor/d3/d3.js \
	node_modules \
	bin \
	public

# install Ruby Gem development dependencies
.PHONY: bin
bin:
	bundle install --binstubs --quiet

# clean, make ... and also build and deploy the Java resources
.PHONY: everything
everything:
	$(MAKE) clean
	$(MAKE) all
	$(MAKE) jnlp-all

.PHONY: src
src: \
	$(MARKDOWN_FILES) \
	$(LAB_JS_FILES) \
	$(LAB_JS_FILES:.js=.min.js) \
	$(HAML_FILES) \
	$(SASS_FILES) \
	$(COFFEESCRIPT_FILES) \
	$(INTERACTIVE_FILES) \
	public/interactives.html \
	public/embeddable.html \
	public/browser-check.html \
	public/interactives.json \
	public/application.js \
	public/lab/lab.json

# rebuild html files that use partials based on settings in project configuration
public/interactives.html: config/config.yml
public/embeddable.html: config/config.yml

.PHONY: clean
clean:
	ruby script/check-development-dependencies.rb
	# remove the .bundle dir in case we are running this after running: make clean-for-tests
	# which creates a persistent bundle grouping after installing just the minimum
	# necessary set of gems for running tests using the arguments: --without development app
	# Would be nice if bundle install had a --withall option to cancel this persistence.
	rm -rf .bundle
	# install/update Ruby Gems
	bundle install --binstubs
	$(MAKE) clean-finish

# Like clean without installing development-related Ruby Gems,intended
# to make testing faster on a continuous integration server.
# Minimal project build and run tests: make clean-for-tests; make test-src
.PHONY: clean-for-tests
clean-for-tests:
	ruby script/check-development-dependencies.rb
	# install/update Ruby Gems
	bundle install --binstubs --without development app
	$(MAKE) clean-finish

# public dir cleanup.
.PHONY: clean-finish
clean-finish:
	mkdir -p public
	$(MAKE) clean-public
	# Remove Lab auto-generated files.
	rm -f src/lab/lab.config.js
	rm -f src/lab/lab.version.js
	# Remove Node modules.
	rm -rf node_modules
	-$(MAKE) submodule-update || $(MAKE) submodule-update-tags
	# Remove generated products in vendor libraries
	rm -f vendor/jquery/dist/jquery*.js
	rm -f vendor/jquery-ui/dist/jquery-ui*.js
	# hack to always download a new copy of grunt-contrib-jshint
	# because of packaging issues with an unresolved jshint depedency when
	# an older version of jshint is installed
	if [ -d vendor/jquery/node_modules/grunt-contrib-jshint ]; then rm -rf vendor/jquery/node_modules/grunt-contrib-jshint; fi
	if [ -d vendor/jquery-ui/node_modules/grunt-contrib-jshint ]; then rm -rf vendor/jquery-ui/node_modules/grunt-contrib-jshint; fi

# public dir cleanup.
.PHONY: clean-public
clean-public:
	bash -O extglob -c 'rm -rf public/!(.git|jnlp|version)'

# versioned archives cleanup.
.PHONY: clean-archives
clean-archives:
	rm -rf version
	rm -rf public/version

# separate tasks for building and cleaning Java resources since they do not get updated often
.PHONY: jnlp-all
jnlp-all: clean-jnlp \
	public/jnlp \
	copy-resources-to-public
	script/build-and-deploy-jars.rb --maven-update

.PHONY: clean-jnlp
clean-jnlp:
	rm -rf public/jnlp

# create symbolic link to support references to old location for Interactives
.PHONY: symbolic-links
symbolic-links:
	cd public/examples; if [ ! -L interactives ]; then ln -s ../ interactives; fi

# ------------------------------------------------
#
#   Testing
#
# ------------------------------------------------

.PHONY: test
test: test/layout.html \
	vendor/d3 \
	public \
	$(LAB_JS_FILES) \
	$(JS_FILES:.js=.min.js)
	@echo
	@echo 'Mocha tests ...'
	@$(MOCHA)
	@echo 'Vows tests ...'
	@$(VOWS)
	@echo

# Run all tests WITHOUT trying to build Lab JS first. Run 'make test' to build & test.
# Minimal project build and run tests: make clean-for-tests; make test-src
.PHONY: test-src
test-src: test/layout.html \
	vendor/d3 \
	vendor/d3/d3.js \
	node_modules \
	public/vendor/d3 \
	public/vendor/d3-plugins \
	public/vendor/jquery/jquery.min.js \
	public/vendor/jquery-ui/jquery-ui.min.js \
	public/vendor/jquery-ui-touch-punch/jquery.ui.touch-punch.min.js \
	public/vendor/jquery-selectBoxIt \
	public/vendor/jquery-context-menu \
	src/lab/lab.version.js \
	src/lab/lab.config.js
	mkdir -p public/imports/legacy-mw-content/converted/conversion-and-physics-examples
	./node-bin/convert-mml-files --path=imports/legacy-mw-content/conversion-and-physics-examples/
	@echo 'Running Mocha tests ...'
	@$(MOCHA)
	@echo 'Running Vows tests ...'
	@$(VOWS)

# run vows test WITHOUT trying to build Lab JS first. Run 'make; make test-mocha' to build & test.
.PHONY: test-vows
test-vows:
	@echo 'Running Vows tests ...'
	@$(VOWS)

# run mocha test WITHOUT trying to build Lab JS first. Run 'make; make test-mocha' to build & test.
.PHONY: test-mocha
test-mocha:
	@echo 'Running Mocha tests ...'
	@$(MOCHA)

.PHONY: debug-mocha
debug-mocha:
	@echo 'Running Mocha tests in debug mode...'
	@$(MOCHA) --debug-brk

%.min.js: %.js
	@rm -f $@
ifndef LAB_DEVELOPMENT
	$(JS_COMPILER) < $< > $@
	@chmod ug+w $@
else
endif

.PHONY: public/test
public/test: public/embeddable-test-mocha.html
	mkdir -p public/test
	cp node_modules/mocha/mocha.js public/test
	cp node_modules/mocha/mocha.css public/test
	cp node_modules/chai/chai.js public/test
	cp test/test1.js public/test
	./node_modules/mocha-phantomjs/bin/mocha-phantomjs -R dot 'public/embeddable-test-mocha.html#interactives/samples/1-oil-and-water-shake.json'

# ------------------------------------------------
#
#   Submodules
#
# ------------------------------------------------

vendor/d3:
	submodule-update

.PHONY: submodule-update
submodule-update:
	git submodule update --init --recursive

.PHONY: submodule-update-tags
submodule-update-tags:
	git submodule sync
	git submodule foreach --recursive 'git fetch --tags'
	git submodule update --init --recursive

# ------------------------------------------------
#
#   Node modules
#
# ------------------------------------------------

node_modules: node_modules/d3 \
	node_modules/arrays
	npm install

node_modules/d3:
	npm install vendor/d3

node_modules/arrays:
	npm install src/modules/arrays

# ------------------------------------------------
#
#   public/
#
# ------------------------------------------------

public: \
	copy-resources-to-public \
	public/lab \
	public/vendor \
	public/resources \
	public/examples \
	public/doc \
	public/experiments \
	public/imports \
	public/jnlp
	script/update-git-commit-and-branch.rb
	$(MAKE) src

# copy everything (including symbolic links) except files that are
# used to generate resources from src/ to public/
.PHONY: copy-resources-to-public
copy-resources-to-public:
	rsync -aq --exclude='helpers/' --exclude='layouts/' --exclude='modules/' --exclude='sass/' --exclude='vendor/' --exclude='lab/' --filter '+ */' --exclude='*.haml' --exclude='*.sass' --exclude='*.scss' --exclude='*.yaml' --exclude='*.coffee' --exclude='*.rb' --exclude='*.md' src/ public/

public/examples:
	mkdir -p public/examples

public/doc: \
	public/doc/interactives \
	public/doc/models

public/doc/interactives:
	mkdir -p public/doc/interactives

public/doc/models:
	mkdir -p public/doc/models

.PHONY: public/experiments
public/experiments:
	mkdir -p public/experiments

.PHONY: public/jnlp
public/jnlp:
	mkdir -p public/jnlp

# ------------------------------------------------
#
#   public/imports
#
# Copy model resources imported from legacy Java applications and
# process model-definitions generating JSON forms.
#
# ------------------------------------------------

# MML->JSON conversion uses MD2D models for validation and default values handling
# so it depends on appropriate sources.
.PHONY: public/imports
public/imports: \
	$(MD2D_SRC_FILES) \
	$(COMMON_SRC_FILES)
	mkdir -p public/imports
	rsync -aq imports/ public/imports/
	$(MAKE) convert-mml
	rsync -aq --exclude 'converted/***' --filter '+ */'  --prune-empty-dirs --exclude '*.mml' --exclude '*.cml' --exclude '.*' --exclude '/*' public/imports/legacy-mw-content/ public/imports/legacy-mw-content/converted/

.PHONY: convert-mml
convert-mml:
	./node-bin/convert-mml-files
	./node-bin/create-mml-html-index
	./src/helpers/md2d/post-batch-processor.rb

.PHONY: convert-all-mml
convert-all-mml:
	./node-bin/convert-mml-files -a
	./node-bin/create-mml-html-index
	./src/helpers/md2d/post-batch-processor.rb

public/resources:
	cp -R ./src/resources ./public/

# ------------------------------------------------
#
#   public/lab
#
# Generates the Lab Framework JavaScript resources
#
# ------------------------------------------------

public/lab:
	mkdir -p public/lab

public/lab/lab.json: \
	src/lab/common/controllers/interactive-metadata.js \
	src/lab/energy2d/metadata.js \
	src/lab/md2d/models/metadata.js \
	src/lab/sensor/metadata.js \
	src/lab/signal-generator/metadata.js \
	src/lab/solar-system/models/metadata.js
	node src/helpers/lab.json.js

public/lab/lab.js: \
	$(LAB_SRC_FILES) \
	src/lab/lab.version.js \
	src/lab/lab.config.js
	$(R_OPTIMIZER) -o src/lab/lab.build.js

src/lab/lab.version.js: \
	script/generate-js-version.rb \
	src/lab/git-commit \
	src/lab/git-dirty \
	src/lab/git-branch-name
	./script/generate-js-version.rb

src/lab/git-commit:
	./script/update-git-commit-and-branch.rb

src/lab/git-branch-name:
	./script/update-git-commit-and-branch.rb

src/lab/git-dirty:
	./script/update-git-commit-and-branch.rb

ifdef STATIC
src/lab/lab.config.js:
	LAB_STATIC=true ./script/generate-js-config.rb
else
src/lab/lab.config.js: \
	script/generate-js-config.rb \
	config/config.yml
	./script/generate-js-config.rb
endif

public/lab/lab.grapher.js: \
	$(GRAPHER_SRC_FILES) \
	$(COMMON_SRC_FILES)
	$(R_OPTIMIZER) -o src/lab/grapher/grapher.build.js

public/lab/lab.import-export.js: \
	$(IMPORT_EXPORT_SRC_FILES) \
	$(COMMON_SRC_FILES)
	$(R_OPTIMIZER) -o src/lab/import-export/import-export.build.js

public/lab/lab.iframe-phone.js: \
	$(IFRAME_PHONE_SRC_FILES)
	$(R_OPTIMIZER) -o src/lab/iframe-phone/iframe-phone.build.js

public/lab/lab.sensor-applet.js: \
	$(SENSOR_APPLET_SRC_FILES)
	$(R_OPTIMIZER) -o src/lab/sensor-applet/sensor-applet.build.js

# ------------------------------------------------
#
#   public/vendor
#
# External frameworks are built from git submodules checked out into vendor/.
# Just the generated libraries and licenses are copied to public/vendor
#
# ------------------------------------------------

public/vendor: \
	public/vendor/d3 \
	public/vendor/d3-plugins \
	public/vendor/jquery/jquery.min.js \
	public/vendor/jquery-ui/jquery-ui.min.js \
	public/vendor/jquery-ui-touch-punch/jquery.ui.touch-punch.min.js \
	public/vendor/jquery-selectBoxIt \
	public/vendor/tinysort/jquery.tinysort.js \
	public/vendor/jquery-context-menu \
	public/vendor/science.js \
	public/vendor/modernizr \
	public/vendor/sizzle \
	public/vendor/hijs \
	public/vendor/mathjax \
	public/vendor/fonts \
	public/vendor/codemirror \
	public/vendor/dsp.js \
	public/vendor/requirejs \
	public/vendor/text \
	public/vendor/domReady \
	public/vendor/fingerprintjs \
	public/favicon.ico

public/vendor/dsp.js:
	mkdir -p public/vendor/dsp.js
	cp vendor/dsp.js/dsp.js public/vendor/dsp.js
	cp vendor/dsp.js/LICENSE public/vendor/dsp.js/LICENSE
	cp vendor/dsp.js/README public/vendor/dsp.js/README

public/vendor/d3: vendor/d3
	mkdir -p public/vendor/d3
	cp vendor/d3/d3*.js public/vendor/d3
	cp vendor/d3/LICENSE public/vendor/d3/LICENSE
	cp vendor/d3/README.md public/vendor/d3/README.md

public/vendor/d3-plugins:
	mkdir -p public/vendor/d3-plugins/cie
	cp vendor/d3-plugins/LICENSE public/vendor/d3-plugins/LICENSE
	cp vendor/d3-plugins/README.md public/vendor/d3-plugins/README.md
	cp vendor/d3-plugins/cie/*.js public/vendor/d3-plugins/cie
	cp vendor/d3-plugins/cie/README.md public/vendor/d3-plugins/cie/README.md

public/vendor/jquery-ui-touch-punch/jquery.ui.touch-punch.min.js: \
	public/vendor/jquery-ui-touch-punch
	cp vendor/jquery-ui-touch-punch/jquery.ui.touch-punch.min.js public/vendor/jquery-ui-touch-punch

public/vendor/jquery-ui-touch-punch:
	mkdir -p public/vendor/jquery-ui-touch-punch

public/vendor/jquery-selectBoxIt:
	mkdir -p public/vendor/jquery-selectBoxIt
	cp vendor/jquery-selectBoxIt/src/javascripts/jquery.selectBoxIt.min.js public/vendor/jquery-selectBoxIt/jquery.selectBoxIt.min.js
	cp vendor/jquery-selectBoxIt/src/stylesheets/jquery.selectBoxIt.css public/vendor/jquery-selectBoxIt/jquery.selectBoxIt.css

public/vendor/jquery-context-menu:
	mkdir -p public/vendor/jquery-context-menu
	cp vendor/jquery-context-menu/src/jquery.contextMenu.js public/vendor/jquery-context-menu
	cp vendor/jquery-context-menu/src/jquery.contextMenu.css public/vendor/jquery-context-menu

public/vendor/jquery/jquery.min.js: \
	vendor/jquery/dist/jquery.min.js \
	public/vendor/jquery
	cp vendor/jquery/dist/jquery*.js public/vendor/jquery
	cp vendor/jquery/dist/jquery.min.map public/vendor/jquery
	cp vendor/jquery/MIT-LICENSE.txt public/vendor/jquery
	cp vendor/jquery/README.md public/vendor/jquery

public/vendor/jquery:
	mkdir -p public/vendor/jquery

public/vendor/jquery-ui/jquery-ui.min.js: \
	vendor/jquery-ui/dist/jquery-ui.min.js \
	public/vendor/jquery-ui
	cp -r vendor/jquery-ui/dist/* public/vendor/jquery-ui
	cp -r vendor/jquery-ui/themes/base/images public/vendor/jquery-ui
	cp vendor/jquery-ui/MIT-LICENSE.txt public/vendor/jquery-ui

public/vendor/jquery-ui:
	mkdir -p public/vendor/jquery-ui

public/vendor/tinysort:
	mkdir -p public/vendor/tinysort

public/vendor/tinysort/jquery.tinysort.js: \
	public/vendor/tinysort
	cp -r vendor/tinysort/src/* public/vendor/tinysort
	cp vendor/tinysort/README.md public/vendor/tinysort

public/vendor/science.js:
	mkdir -p public/vendor/science.js
	cp vendor/science.js/science*.js public/vendor/science.js
	cp vendor/science.js/LICENSE public/vendor/science.js
	cp vendor/science.js/README.md public/vendor/science.js

public/vendor/modernizr:
	mkdir -p public/vendor/modernizr
	cp vendor/modernizr/modernizr.js public/vendor/modernizr
	cp vendor/modernizr/readme.md public/vendor/modernizr

public/vendor/sizzle:
	mkdir -p public/vendor/sizzle
	cp vendor/sizzle/sizzle.js public/vendor/sizzle
	cp vendor/sizzle/LICENSE public/vendor/sizzle
	cp vendor/sizzle/README public/vendor/sizzle

public/vendor/hijs:
	mkdir -p public/vendor/hijs
	cp vendor/hijs/hijs.js public/vendor/hijs
	cp vendor/hijs/LICENSE public/vendor/hijs
	cp vendor/hijs/README.md public/vendor/hijs

public/vendor/mathjax:
	mkdir -p public/vendor/mathjax
	cp vendor/mathjax/MathJax.js public/vendor/mathjax
	cp vendor/mathjax/LICENSE public/vendor/mathjax
	cp vendor/mathjax/README.md public/vendor/mathjax
	cp -R vendor/mathjax/jax public/vendor/mathjax
	cp -R vendor/mathjax/extensions public/vendor/mathjax
	cp -R vendor/mathjax/images public/vendor/mathjax
	cp -R vendor/mathjax/fonts public/vendor/mathjax
	cp -R vendor/mathjax/config public/vendor/mathjax

public/vendor/fonts: $(FONT_FOLDERS)
	mkdir -p public/vendor/fonts
	cp -R vendor/fonts public/vendor/
	rm -rf public/vendor/fonts/Font-Awesome/.git*
	rm -f public/vendor/fonts/Font-Awesome/.gitignore
	rm -rf public/vendor/fonts/Font-Awesome/less
	rm -rf public/vendor/fonts/Font-Awesome/sass

public/vendor/requirejs:
	mkdir -p public/vendor/requirejs
	cp vendor/requirejs/require.js public/vendor/requirejs
	cp vendor/requirejs/LICENSE public/vendor/requirejs
	cp vendor/requirejs/README.md public/vendor/requirejs

public/vendor/text:
	mkdir -p public/vendor/text
	cp vendor/text/text.js public/vendor/text
	cp vendor/text/LICENSE public/vendor/text
	cp vendor/text/README.md public/vendor/text

public/vendor/domReady:
	mkdir -p public/vendor/domReady
	cp vendor/domReady/domReady.js public/vendor/domReady
	cp vendor/domReady/LICENSE public/vendor/domReady
	cp vendor/domReady/README.md public/vendor/domReady

public/vendor/codemirror:
	mkdir -p public/vendor/codemirror
	cp vendor/codemirror/LICENSE public/vendor/codemirror
	cp vendor/codemirror/README.md public/vendor/codemirror
	cp -R vendor/codemirror/lib public/vendor/codemirror
	cp -R vendor/codemirror/addon public/vendor/codemirror
	cp -R vendor/codemirror/mode public/vendor/codemirror
	cp -R vendor/codemirror/theme public/vendor/codemirror
	cp -R vendor/codemirror/keymap public/vendor/codemirror
	# remove codemirror modules excluded by incompatible licensing
	rm -rf public/vendor/codemirror/mode/go
	rm -rf public/vendor/codemirror/mode/rst
	rm -rf public/vendor/codemirror/mode/verilog

public/vendor/fingerprintjs:
	mkdir -p public/vendor/fingerprintjs
	cp vendor/fingerprintjs/fingerprint.min.js public/vendor/fingerprintjs
	cp vendor/fingerprintjs/README.md public/vendor/fingerprintjs

public/favicon.ico:
	cp -f src/favicon.ico public/favicon.ico

vendor/jquery/dist/jquery.min.js: vendor/jquery
	cd vendor/jquery; npm install; \
	 npm install grunt-cli; \
	 ./node_modules/grunt-cli/bin/grunt

vendor/jquery:
	git submodule update --init --recursive

vendor/jquery-ui/dist/jquery-ui.min.js: vendor/jquery-ui
	cd vendor/jquery-ui; npm install; \
	npm install grunt-cli; \
	./node_modules/grunt-cli/bin/grunt build

vendor/jquery-ui:
	git submodule update --init --recursive

# ------------------------------------------------
#
#   targets for generating html, js, and css resources
#
# ------------------------------------------------

public/lab/lab.mw-helpers.js: src/mw-helpers/*.coffee
	cat $^ | $(COFFEESCRIPT_COMPILER) --stdio --print > $@
	@chmod ug+w $@

test/%.html: test/%.html.haml
	haml $< $@

public/%.html: src/%.html.haml
	haml -r ./script/setup.rb $< $@

public/%.html: src/%.html
	cp $< $@

public/%.css: src/%.css
	cp $< $@

public/grapher.css: src/grapher.sass \
	src/sass/lab/_colors.sass \
	src/sass/lab/_grapher.sass
	$(SASS_COMPILER) src/grapher.sass public/grapher.css

public/%.css: %.scss
	$(SASS_COMPILER) $< $@

public/%.css: %.sass $(SASS_LAB_LIBRARY_FILES)
	@echo $($<)
	$(SASS_COMPILER) $< $@

public/%.js: %.coffee
	@rm -f $@
	$(COFFEESCRIPT_COMPILER) --compile --print $< > $@

public/%.html: %.md
	@rm -f $@
	$(MARKDOWN_COMPILER) $< --toc-levels 2..6 --template src/layouts/$*.html.erb > $@

public/interactives/%.json: src/interactives/%.json
	@cp $< $@

public/models/%.json: src/models/%.json
	@cp $< $@

.PHONY: public/interactives.json
public/interactives.json: $(INTERACTIVE_FILES)
	$(GENERATE_INTERACTIVE_INDEX)

# ------------------------------------------------
#
#   Targets to help debugging/development of Makefile
#
# ------------------------------------------------

.PHONY: h
h:
	@echo $(HAML_FILES)

.PHONY: s
s:
	@echo $(SASS_FILES)

.PHONY: s1
sl:
	@echo $(SASS_LAB_LIBRARY_FILES)

.PHONY: m
m:
	@echo $(MARKDOWN_FILES)

.PHONY: c
c:
	@echo $(COFFEESCRIPT_FILES)

.PHONY: cm
cm:
	@echo $(COMMON_SRC_FILES)

.PHONY: md2
md2:
	@echo $(MD2D_SRC_FILES)

.PHONY: gr
gr:
	@echo $(GRAPHER_SRC_FILES)

.PHONY: int
int:
	@echo $(INTERACTIVE_FILES)

.PHONY: sources
sources:
	@echo $(LAB_SRC_FILES)
