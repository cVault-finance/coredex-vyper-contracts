# @version ^0.3.4

owner: address
initialized: bool

event OwnerSet:
    new_owner: address

struct Asset:
    token_address: address
    decimals: int8
    name: String[32]

struct Note:
    list_price: uint256
    list_duration: uint256
    stop_twap_value: uint256
    fill_twap_value: uint256
    intrinsic_value: uint256

event NoteWritten:
    order_owner: address
    order_asset0: Asset
    order_asset1: Asset
    note_id: bytes32

event AssetCreated:
    token: address
    decimals: int8
    name: String[32]


assets: HashMap[address, Asset]
notes: HashMap[bytes32, Note]

@external
def __init__():
    self.owner = msg.sender
    log OwnerSet(msg.sender)

@internal
def _create_note(asset0: Asset, asset1: Asset, ratio: uint256):
    note_id: bytes32 = keccak256(concat(convert(asset0.token_address, bytes20), convert(asset1.token_address, bytes20)))
    log NoteWritten(msg.sender, asset0, asset1, note_id)

@internal
def _create_note_from_addresses(token0: address, token1: address, ratio: uint256):
    note_id: bytes32 = keccak256(concat(convert(token0, bytes20), convert(token1, bytes20)))
    asset0: Asset = self.assets[token0]
    asset1: Asset = self.assets[token1]
    log NoteWritten(msg.sender, asset0, asset1, note_id)

@external
def create_note(token0: address, token1: address, ratio: uint256):
    self._create_note_from_addresses(token0, token1, ratio)

# For ETH notes use token address of 0x30
@internal
def create_asset(token_address: address, decimals: int8, name: String[32]) -> Asset:
    new_asset_type: Asset = Asset({token_address: token_address, decimals: decimals, name: name})
    log AssetCreated(token_address, decimals, name)
    return new_asset_type

@external
def create_test_assets():
    assert msg.sender == self.owner
    assert not self.initialized, "Already initialized test assets"
    self.initialized = True
    eth_asset_type: Asset = self.create_asset(0x3000000000000000000000000000000000000000, 8, "ETH")
    core_asset_type: Asset = self.create_asset(0x62359Ed7505Efc61FF1D56fEF82158CcaffA23D7, 18, "CORE")
    self._create_note(eth_asset_type, core_asset_type, 100)