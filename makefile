PROGRAM := wockito-generator
PROGRAM := your-program-name

# set to false or it will be linked with a main()
EXECUTABLE := true

LIBRARYFILES := ../compiler/bin/wakeobj/std.o
LIBRARYTABLES := $(filter-out $(wildcard ../compiler/bin/waketable/*Test.table), $(wildcard ../compiler/bin/waketable/*.table) ) \
	../wUnit/bin/waketable/Asserts.table \
	../wUnit/bin/waketable/TestResultReporter.table \
	../table-reflection-parser/bin/waketable/WakeClass.table \
	../table-reflection-parser/bin/waketable/WakeType.table \
	../table-reflection-parser/bin/waketable/WakeProperty.table \
	../table-reflection-parser/bin/waketable/TableDirectoryScanner.table \
	../table-reflection-parser/bin/waketable/TableFileReader.table \
	../std/bin/waketable/Map.table

TESTLIBRARYFILES := \
	../wUnit/bin/wakeobj/TestResultReporter.o

LIBRARYFILES := \
	../wUnit/bin/wakeobj/Asserts.o \
	../table-reflection-parser/bin/wakeobj/WakeClass.o \
	../table-reflection-parser/bin/wakeobj/WakeType.o \
	../table-reflection-parser/bin/wakeobj/WakeProperty.o \
	../table-reflection-parser/bin/wakeobj/TableDirectoryScanner.o \
	../table-reflection-parser/bin/wakeobj/TableFileReader.o \
	../std/bin/wakeobj/Map.o \
	../compiler/bin/wakeobj/std.o

SRCDIR := src
TESTDIR := test
TABLEDIR := bin/waketable
OBJECTDIR := bin/wakeobj
SRCDEPDIR := bin/srcdep
TESTDEPDIR := bin/testdep

SOURCEFILES := $(wildcard $(SRCDIR)/*.wk)
TESTFILES := $(wildcard $(TESTDIR)/*.wk)

DEPFILES := ${SOURCEFILES:.wk=.d} ${TESTFILES:.wk=.d}
OBJECTFILES := $(subst $(SRCDIR),$(OBJECTDIR),${SOURCEFILES:.wk=.o})
TESTOBJECTFILES := $(subst $(TESTDIR),$(OBJECTDIR),${TESTFILES:.wk=.o})
TABLEFILES := $(subst $(SRCDIR),$(TABLEDIR),${SOURCEFILES:.wk=.table})
TESTTABLEFILES := $(subst $(TESTDIR),$(TABLEDIR),${TESTFILES:.wk=.table})

bin/$(PROGRAM): $(OBJECTFILES) $(TABLEFILES) $(LIBRARYFILES) tests
ifeq ($(EXECUTABLE),true)
		wake -l -d $(TABLEDIR) -o bin/$(PROGRAM) $(OBJECTFILES) $(LIBRARYFILES)
endif

.PHONY:
tests: bin/$(PROGRAM)-test
	node bin/$(PROGRAM)-test

bin/$(PROGRAM)-test: $(OBJECTFILES) $(TESTLIBRARYFILES) $(LIBRARYFILES) $(TABLEFILES) $(TESTOBJECTFILES) $(TESTTABLEFILES)
	wunit-compiler
	wake bin/TestSuite.wk -d $(TABLEDIR) -o bin/TestSuite.o
	wake -l -d $(TABLEDIR) $(OBJECTFILES) $(TESTOBJECTFILES) $(TESTLIBRARYFILES) $(LIBRARYFILES) bin/TestSuite.o -o bin/$(PROGRAM)-test -c TestSuite -m 'tests()'

to-md5 = $1 $(addsuffix .md5,$1)

%.md5: % FORCE
	@$(if $(filter-out $(shell cat $@ 2>/dev/null),$(shell md5sum $*)),md5sum $* > $@)

FORCE:

$(addprefix $(TABLEDIR)/,$(notdir $(LIBRARYTABLES))): $(LIBRARYTABLES)
	cp $(LIBRARYTABLES) $(TABLEDIR)

$(SRCDEPDIR)/%.d: $(SRCDIR)/%.wk
	@./generate-makefile.sh $< $(TABLEDIR) > $@

$(TESTDEPDIR)/%.d: $(TESTDIR)/%.wk
	@./generate-makefile.sh $< $(TABLEDIR) > $@

$(TABLEDIR)/%.table: $(SRCDIR)/%.wk
	wake $< -d $(TABLEDIR) -t

$(OBJECTDIR)/%.o: $(SRCDIR)/%.wk
	wake $< -d $(TABLEDIR) -o $@

$(TABLEDIR)/%Test.table: $(TESTDIR)/%Test.wk
	wake $< -d $(TABLEDIR) -t

$(OBJECTDIR)/%Test.o: $(TESTDIR)/%Test.wk
	wake $< -d $(TABLEDIR) -o $@

ifneq "$(MAKECMDGOALS)" "clean"
-include $(subst $(SRCDIR),$(SRCDEPDIR),${SOURCEFILES:.wk=.d})
-include $(subst $(TESTDIR),$(TESTDEPDIR),${TESTFILES:.wk=.d})
endif

clean:
	rm $(TABLEFILES) || :
	rm $(TESTTABLEFILES) || :
	rm $(DEPFILES) || :
	rm $(TESTOBJECTFILES) || :
	rm $(OBJECTFILES) || :
	rm bin/TestSuite.wk || :
	rm bin/TestSuite.o || :
	rm bin/$(PROGRAM) || :
	rm bin/$(PROGRAM)-test || :
	find . -name '*.md5' -delete
