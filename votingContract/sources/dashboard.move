/// Module: votingcontract
module votingcontract::dashboard;


// === Imports ===
use sui::types;

// === Errors ===
const EInvalidOtw:u64=0;
const EDuplicateProposal:u64=1;

// === Constants ===

// === Structs ===

public struct Dashboard has key {
  id: UID,
  proposals_ids: vector<ID>,
}
public struct AdminCap has key {
  id: UID,
}
// OTW
public struct DASHBOARD has drop{}

// === Events ===

// === Method Aliases ===


// ===Initialization ===
fun init (otw:DASHBOARD, ctx: &mut TxContext) {
  new(otw,ctx);
  let admin_cap = AdminCap{
    id:object::new(ctx),
  };
  transfer::transfer(admin_cap,ctx.sender());
}
// === Public Functions ===
public fun new(otw: DASHBOARD, ctx: &mut TxContext) {
  assert!(types::is_one_time_witness(&otw), EInvalidOtw);
  
  let dashboard = Dashboard{
    id:object::new(ctx),
    proposals_ids: vector::empty(),
  };
  transfer::share_object(dashboard);
}


// === View Functions ===
public fun get_proposals_ids(self: &Dashboard): vector<ID>{
  self.proposals_ids
}

// === Admin Functions ===
public fun register_proposal(self: &mut Dashboard, _admin_cap: &AdminCap,proposal_id:ID){
assert!(!self.proposals_ids.contains(&proposal_id),EDuplicateProposal);
self.proposals_ids.push_back(proposal_id);
}

// === Package Functions ===

// === Private Functions ===

// === Test Functions ===
#[test_only]
public fun issue_admin_cap(ctx: &mut TxContext){
transfer::transfer(
  AdminCap{id:object::new(ctx)},
  ctx.sender()
);
}
#[test_only]
public fun new_otw(_ctx: &mut TxContext):DASHBOARD{
 DASHBOARD{}
}