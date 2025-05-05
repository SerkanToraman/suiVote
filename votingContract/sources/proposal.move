/// Module: votingcontract
module votingcontract::proposal;


// === Imports ===
use std::string::String;
use sui::table::{Self, Table};
use votingcontract::dashboard::AdminCap;


// === Errors ===
const EDuplicateVote: u64 = 0;

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
  voters:Table<address,bool>,
}


// === Events ===

// === Method Aliases ===


// ===Initialization ===

// === Public Functions ===
public fun vote(self:&mut Proposal,vote_yes:bool,ctx:&mut TxContext){
   assert!(!self.voters.contains(ctx.sender()), EDuplicateVote);
  if(vote_yes){
    self.voted_yes_count = self.voted_yes_count + 1;
  }else{
    self.voted_no_count = self.voted_no_count + 1;
  };
   
  self.voters.add(ctx.sender(), vote_yes);
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

public fun voters(self: &Proposal):&Table<address,bool>{
  &self.voters
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
    voters:table::new(ctx),
  };
  let id = proposal.id.to_inner();
  transfer::share_object(proposal);
  id
}

// === Package Functions ===

// === Private Functions ===

// === Test Functions ===

