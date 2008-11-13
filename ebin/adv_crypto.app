{application, adv_crypto,
   [{description, "ADV_CRYPTO version 1"},
    {vsn, "1.5.2.1"},
    {modules, [adv_crypto,
	       adv_crypto_app,
	       adv_crypto_sup,
	       adv_crypto_server]},
    {registered, [adv_crypto_sup, adv_crypto_server]},
    {applications, [kernel, stdlib]},
    {env, []},
    {mod, {adv_crypto_app, []}}]}.


