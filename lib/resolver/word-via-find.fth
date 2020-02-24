\ 2018-08, 2020-02
\ ruv

255 dup constant size-buf-for-find allocate throw constant buf-for-find

: carbon-c-for-find ( c-addr u -- c-addr2 )
  dup size-buf-for-find u> if -19 throw then
  buf-for-find 2dup c! dup >r char+ swap move r>
;

: resolve-word-stateful ( c-addr u -- xt imm-flag tt | c-addr u 0 )
  \ NB: the result depends on STATE in the general case
  2dup carbon-c-for-find find dup if 2nip 1 = ['] tt-word exit then nip
;
: resolve-native-stateful ( c-addr u -- xt tt | c-addr u 0 )
  resolve-word-stateful dup if 2drop ['] tt-xt then
;
