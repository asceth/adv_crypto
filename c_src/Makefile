CC = gcc
CFLAGS = -g -O2 -Wall
CPPFLAGS = -I/usr/local/ssl/include

SSL_CFLAGS = -DHAVE_SSL
SSL_LIBS = -L/usr/local/ssl/lib -lssl -lcrypto

ERLANG_CFLAGS = -I/usr/local/lib/erlang/lib/erl_interface-3.5.8/include -I/usr/local/lib/erlang/usr/include
ERLANG_LIBS = -L/usr/local/lib/erlang/lib/erl_interface-3.5.8/lib -lerl_interface -lei

ifeq ($(shell uname),Darwin)
	DYNAMIC_LIB_CFLAGS = -fPIC -bundle -flat_namespace -undefined suppress
else
# Assume Linux-style dynamic library flags
	DYNAMIC_LIB_CFLAGS = -fpic -shared
endif

EFLAGS += -I ../../include
EFLAGS += -pz ..

# make debug=true to compile Erlang module with debug informations.
ifdef debug
	EFLAGS+=+debug_info
endif

ERLSHLIBS = adv_crypto_drv.so
OUTDIR = ./

all:    $(ERLSHLIBS) copy-files

adv_crypto_drv.so:	%.so:	%.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) \
		$(subst ../,,$(subst .so,.c,$@)) \
		$(LIBS) \
		$(SSL_LIBS) \
		$(SSL_CFLAGS) \
		$(ERLANG_LIBS) \
		$(ERLANG_CFLAGS) \
		-o $@ \
		$(DYNAMIC_LIB_CFLAGS)

copy-files:
	cp ./*.so ../priv/lib/

clean:
	rm -f $(ERLSHLIBS)

distclean: clean
	rm -f Makefile


