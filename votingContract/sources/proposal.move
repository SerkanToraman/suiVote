/// Module: votingcontract
module votingcontract::proposal;


// === Imports ===
use std::string::String;
use sui::table::{Self, Table};
use sui::url::{Url, new_unsafe_from_bytes};
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

public struct VoteProofNFT has key {
  id:UID,
  proposal_id:ID,
  name:String,
  description:String,
  url:Url,
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

  issue_vote_proof(self, vote_yes, ctx);

}


// === View Functions ===
public fun vote_proof_url(self: &VoteProofNFT):Url{
  self.url
}

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
fun issue_vote_proof(proposal: &Proposal, vote_yes:bool, ctx: &mut TxContext){
  let mut name = b"NFT".to_string();
  name.append(proposal.title);

  let mut description = b"Proof of voting on".to_string();
  let proposal_address= object::id_address(proposal).to_string();
  description.append(proposal_address);

  let vote_yes_image = new_unsafe_from_bytes(b"https://thrangra.sirv.com/vote_yes_nft.jpg");
  let vote_no_image = new_unsafe_from_bytes(b"https://thrangra.sirv.com/vote_no_nft.jpg");

  let url = if(vote_yes){
    vote_yes_image
  }else{
    vote_no_image
  };

  let vote_proof_nft = VoteProofNFT{
    id:object::new(ctx),
    // proposal_id:proposal.id.to_inner(),
    proposal_id:object::id(proposal),
    name,
    description,
    url,
  };
  transfer::transfer(vote_proof_nft, ctx.sender());
  
}



