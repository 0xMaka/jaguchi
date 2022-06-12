# @version ^0.3.3
# @title Jaguchiv01
# @notice Stores faucet funds in Bento, 
#  earning additional reserves when idle.
#  Can top up Operators balance if too low.
# @author Maka
#--

#-- interface -- 
interface SukoshiBento:
  def deposit(
    token: address,  # token to push
    from_: address,  # address to pull from
    to: address,     # account to push to
    amount: uint256, # amount to push
    share: uint256   # 0 if amount not 0
  ) -> (uint256, uint256): payable

  def withdraw(
    token: address,  # token to push        
    from_: address,  # account to pull from
    to:   address,   # address to push to
    amount: uint256, # amount to push
    share: uint256   # 0 if amount not 0
  ) -> (uint256, uint256): nonpayable
#--

#-- defines --
#
# hardcoded bento address to save on gas
BENTOBOX: constant(address) = 0xF5BCE5077908a1b7370B9ae04AdC565EBd643966
# contract controller
admin: address
# admin only toggle for additional functionality
admin_only: bool
# contract operator (an eoa that can call the contract)
operator: public(address)
# max amount to withdraw on each request
max_disperse: uint256
# min amount to hold at 'operator' for gas
min_reserve: uint256
# mapping of addresses with restricted access to functionality
whitelisted: public(HashMap[address, bool])
#--

#-- functions --
#
#- on initialisation
@external
def __init__():
  self.admin = msg.sender
  self.admin_only = True
  self.whitelisted[msg.sender] = True
  self.max_disperse = 0
  self.min_reserve = 0

#- core functionality of 'littlebento'
#
# deposits 'eth' to this contracts account
@internal
@payable
def _deposit(_val: uint256):
  SukoshiBento(BENTOBOX).deposit(
    ZERO_ADDRESS,
    self,
    self,
    _val,
    0,
    value=_val
  )
# withdraws _val of 'eth' from this contracts account
@internal
def _withdraw(_des: address, _val: uint256):
  SukoshiBento(BENTOBOX).withdraw(
    ZERO_ADDRESS,
    self,
    _des,
    _val,
    0
  )

#- core functionality of self
#
# the fallback function and intended way to deposit
@external
@payable
def __default__():
  assert len(msg.data) == 0 
  self._deposit(msg.value)
# set a new admin
@external
def set_admin(_new_admin: address):
  assert msg.sender == self.admin
  self.whitelisted[_new_admin] = True
  self.admin = _new_admin
# set a new operator
@external
def set_operator(_new_operator: address):
  assert msg.sender == self.admin
  self.whitelisted[self.operator] = False
  self.whitelisted[_new_operator] = True
  self.operator = _new_operator
# add/remove address from whitelist
@external
def set_whitelist(_address: address, _bool: bool):
  assert msg.sender == self.admin 
  self.whitelisted[_address] = _bool
# set max to grant on request
@external
def set_disperse(_amount: uint256):  
  assert msg.sender == self.admin 
  self.max_disperse = _amount
# set min to retain for gas
@external
def set_reserve(_amount: uint256):  
  assert msg.sender == self.admin 
  self.min_reserve = _amount
# grant faucet funds to an address
@external
def grant(_beneficiary: address):
  if (self.admin_only == False):
    assert self.whitelisted[msg.sender] == True
    if (self.operator.balance < self.min_reserve):
      self._withdraw(self.operator, self.min_reserve)
  else: 
    assert msg.sender == self.admin 

  self._withdraw(_beneficiary, self.max_disperse)
#--
#
# - 1love
