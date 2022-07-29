# Jaguchi: a sustainable faucet
Exploring the concept of utilizing Bento, and its capacity for securely storing funds while earning yield on idle assets, as a means to contribute towards a faucet's long term sustainability.

Where may be appropriate: 
  - as a permissioned community faucet, that can go periods with low payout volume.
  - dapp onboarding, where amount granted should be enough to cover half a dozen swaps or several app interactions

Where unlikely to be appropriate:
 -  as a permissionless faucet, making frequent payouts.
 -  as a lifejacket, where enough for just one swap should be airdropped. 

Options:
- There must be one admin, but an operator is optional.
- There can only be one of each, though more addresses can be whitelisted.

This allows for a few configurations.

The cheapest, (in terms of gas expense) is where the admin pays while 'admin_only' is toggled True. With cost growing as the number of checks or actions are increased.
When 'admin_only' is toggled False, the caller's address is checked against the whitelist. 
Where only if 'min_reserve' is set to a value greater than zero will we make the external check to operator balance, topping up if needed before performing the intended delivery.

