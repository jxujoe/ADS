OS_NAME ?= $(shell uname)
VPATH = AdsLib
LIB_NAME = AdsLib-$(OS_NAME).a
OBJ_DIR = obj
CXX :=$(CROSS_COMPILE)$(CXX)
CXXFLAGS += -std=c++11
CXXFLAGS += -pedantic
CXXFLAGS += -Wall
CXXFLAGS += -Wextra
CXXFLAGS += -D_GNU_SOURCE
CXXFLAGS += $(ci_cxx_flags)
CPPFLAGS += -I AdsLib/
CPPFLAGS += -I tools/

SRC_FILES = AdsDef.cpp
SRC_FILES += AdsDevice.cpp
SRC_FILES += AdsLib.cpp
SRC_FILES += AdsNotification.cpp
SRC_FILES += AmsConnection.cpp
SRC_FILES += AmsPort.cpp
SRC_FILES += AmsRouter.cpp
SRC_FILES += Log.cpp
SRC_FILES += NotificationDispatcher.cpp
SRC_FILES += Sockets.cpp
SRC_FILES += Frame.cpp

OBJ_FILES = $(SRC_FILES:%.cpp=$(OBJ_DIR)/%.o)


LDFLAGS += -lpthread
LDFLAGS_Darwin += -lc++
LDFLAGS_win32 += -lws2_32
LDFLAGS += $(LDFLAGS_$(OS_NAME))

all: $(LIB_NAME)

$(OBJ_DIR):
	mkdir -p $@

$(OBJ_FILES): | $(OBJ_DIR)
$(OBJ_FILES): $(OBJ_DIR)/%.o: %.cpp
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(LIB_NAME): $(OBJ_FILES)
	$(AR) rvs $@ $?

AdsLibTest.bin: AdsLibTest/main.cpp $(LIB_NAME)
	$(CXX) $^ $(LDFLAGS) $(CPPFLAGS) $(CXXFLAGS) -o $@

AdsLibOOITest.bin: AdsLibOOITest/main.cpp $(LIB_NAME)
	$(CXX) $^ $(LDFLAGS) $(CPPFLAGS) $(CXXFLAGS) -o $@

test: AdsLibTest.bin
	./$<

testOOI: AdsLibOOITest.bin
	./$<

clean:
	rm -rf *.a *.o *.bin AdsLib*Test/*.o $(OBJ_DIR)/*.o

uncrustify:
	uncrustify --no-backup -c tools/uncrustify.cfg AdsLib*/*.h AdsLib*/*.cpp example/*.cpp

prepare-hooks:
	rm -f .git/hooks/pre-commit
	ln -Fv tools/pre-commit.uncrustify .git/hooks/pre-commit
	chmod a+x .git/hooks/pre-commit

.PHONY: clean uncrustify prepare-hooks
