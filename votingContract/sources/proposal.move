/// Module: votingcontract
module votingcontract::proposal;


// === Imports ===
use std::string::String;
use sui::table::{Self, Table};
use sui::url::{Url, new_unsafe_from_bytes};
use sui::clock::{Clock};
use sui::event;
use sui::{display,package};
use votingcontract::dashboard::AdminCap;



// === Errors ===
const EDuplicateVote: u64 = 0;
const EProposalNotActive: u64 = 1;
const EProposalExpired: u64 = 2;
// === Constants ===

// === Enums ===

public enum ProposalStatus has store, drop {
  Active,
  Delisted,
}


// === Structs ===

public struct Proposal has key {
  id:UID,
  title:String,
  description:String,
  voted_yes_count:u64,
  voted_no_count:u64,
  expiration:u64,
  creator:address,
  status:ProposalStatus,
  voters:Table<address,bool>,
}

public struct VoteProofNFT has key {
  id:UID,
  proposal_id:ID,
  name:String,
  description:String,
  url:Url,
}

// ===OTW===

public struct PROPOSAL() has drop;

// === Events ===

public struct VoteRegistered has copy, drop{
  proposal_id:ID,
  voter:address,
  vote_yes:bool,
}

// === Method Aliases ===


// ===Initialization ===
fun init(otw:PROPOSAL,ctx: &mut TxContext){
     let publisher = package::claim(otw, ctx);

     let mut display = display::new<VoteProofNFT>(&publisher, ctx);

    display.add(
        b"name".to_string(),
        b"{name}".to_string(),
    );
    display.add(
        b"description".to_string(),
        b"{description}".to_string(),
    );
    display.add(
      b"proposal_id".to_string(),
      b"{proposal_id}".to_string(),
    );
    display.add(
        b"image_url".to_string(),
        b"{url}".to_string(),
    );

    // Update the version of the display.
    display.update_version();
    transfer::public_transfer(publisher, ctx.sender());
    transfer::public_transfer(display, ctx.sender());
   
}

// === Public Functions ===
//you cannot mutate the clock
public fun vote(self:&mut Proposal,vote_yes:bool, clock: &Clock, ctx:&mut TxContext){
   assert!(!self.voters.contains(ctx.sender()), EDuplicateVote);
   assert!(self.is_active(), EProposalNotActive);
   //clock works in milliseconds
   assert!(self.expiration > clock.timestamp_ms(), EProposalExpired);

  if(vote_yes){
    self.voted_yes_count = self.voted_yes_count + 1;
  }else{
    self.voted_no_count = self.voted_no_count + 1;
  };
   
  self.voters.add(ctx.sender(), vote_yes);

  issue_vote_proof(self, vote_yes, ctx);

  event::emit(VoteRegistered{
    proposal_id:object::id(self),
    voter:ctx.sender(),
    vote_yes,
  });

}


// === View Functions ===

public fun vote_proof_url(self: &VoteProofNFT):Url{
  self.url
}
public fun status(self: &Proposal):&ProposalStatus{
  &self.status
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

public fun is_active (self:&Proposal):bool{
 let status = self.status();

 //pattern matching
 match(status){
  ProposalStatus::Active => true,
  _ => false,
 }
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
    status:ProposalStatus::Active,
    voters:table::new(ctx),
  };
  let id = proposal.id.to_inner();
  transfer::share_object(proposal);
  id
}

fun change_status(
  self:&mut Proposal,
  _admin_cap:&AdminCap,
  status:ProposalStatus,
){
  self.status = status;
}

public fun set_active_status (self:&mut Proposal, _admin_cap:&AdminCap){
  self.change_status(_admin_cap, ProposalStatus::Active);
}

public fun set_delisted_status (self:&mut Proposal, _admin_cap:&AdminCap){
  self.change_status(_admin_cap, ProposalStatus::Delisted);
}

public fun remove_proposal(self:Proposal, _admin_cap:&AdminCap){
  let Proposal{id, title:_, description:_, voted_yes_count:_, voted_no_count:_, expiration:_, creator:_, status:_, voters} = self;  
  //Table its self doesnt have a drop ability so we need to drop the table
  table::drop(voters);
  object::delete(id);
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









