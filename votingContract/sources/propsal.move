/// Module: votingcontract
module votingcontract::proposal;


// === Imports ===
use std::string::String;
use votingcontract::dashboard::AdminCap;


// === Errors ===


// === Constants ===

// === Structs ===

public struct Proposal has key {
  id:UID,
  title:String,
  description:String,
  voted_yes_count:u64,
  voted_no_count:u64,
  expiration:u64,
  creator:address,
  voting_registry: vector<address>,
}


// === Events ===

// === Method Aliases ===


// ===Initialization ===

// === Public Functions ===
public fun create(
  _admin_cap:&AdminCap,
  title:String,
  description:String,
  expiration:u64,
  ctx: &mut TxContext,
):ID{
  let proposal = Proposal{
    id:object::new(ctx),
    title,
    description,
    voted_yes_count:0,
    voted_no_count:0,
    expiration,
    creator:ctx.sender(),
    voting_registry:vector::empty(),
  };
  let id = proposal.id.to_inner();
  transfer::transfer(proposal,ctx.sender());
  id
}


// === View Functions ===
public fun title(self: &Proposal):String{
  self.title
}

public fun description(self: &Proposal):String{
  self.description
}

public fun expiration(self: &Proposal):u64{
  self.expiration
}

public fun voting_registry(self: &Proposal):vector<address>{
  self.voting_registry
}

public fun voted_yes_count(self: &Proposal):u64{
  self.voted_yes_count
}

public fun voted_no_count(self: &Proposal):u64{
  self.voted_no_count
}

public fun creator(self: &Proposal):address{
  self.creator
}


// === Admin Functions ===

// === Package Functions ===

// === Private Functions ===

// === Test Functions ===

