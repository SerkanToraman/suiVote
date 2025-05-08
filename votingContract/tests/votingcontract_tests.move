
#[test_only]
module votingcontract::votingcontract_tests;
// uncomment this line to import the module
use sui::test_scenario;
use votingcontract::dashboard::{Self,AdminCap,Dashboard};
use votingcontract::proposal::{Self,Proposal,VoteProofNFT};
use sui::clock::{Self,Clock};
use sui::url::{new_unsafe_from_bytes};

const EWrongVoteCount: u64 = 0;
const EWrongStatus: u64 = 1;


// 2000000000000 is the time to expire in milliseconds
const TIME_TO_EXPIRE: u64 = 2000000000000;


#[test]
fun test_create_proposal_with_admin_cap() {
    let user = @0xCA;

    let mut scenario = test_scenario::begin(user);
    {
        dashboard::issue_admin_cap(scenario.ctx());
    };
    scenario.next_tx(user);
    {
        let admin_cap = scenario.take_from_sender<AdminCap>();
        new_proposal(&admin_cap,scenario.ctx());
        test_scenario::return_to_sender(&scenario,admin_cap);
    };
    scenario.next_tx(user);
    {
        let created_proposal = scenario.take_shared<Proposal>();
        assert!(created_proposal.title()==b"Test".to_string());
        assert!(created_proposal.description()==b"Test".to_string());
        assert!(created_proposal.expiration()==TIME_TO_EXPIRE);
        assert!(created_proposal.creator()==user);
        assert!(created_proposal.voted_yes_count()==0);
        assert!(created_proposal.voted_no_count()==0);
        assert!(created_proposal.voters().is_empty());
        
        test_scenario::return_shared(created_proposal);

    };
    scenario.end();
}
#[test]
#[expected_failure(abort_code = test_scenario::EEmptyInventory)]
fun test_create_proposal_no_admin_cap(){
    let user = @0xB0B;
    let admin = @0xA01;

    let mut scenario = test_scenario::begin(admin);
    {
        dashboard::issue_admin_cap(scenario.ctx());
    };

    scenario.next_tx(user);
    // this should fail because user does not have admin cap
    {
        let admin_cap = scenario.take_from_sender<AdminCap>();
        new_proposal(&admin_cap, scenario.ctx());
        test_scenario::return_to_sender(&scenario, admin_cap);
    };

    scenario.end();

}

#[test]
fun test_register_proposal_as_admin() {
    let admin = @0xAD;
    let mut scenario = test_scenario::begin(admin);
    {
        let otw = dashboard::new_otw(scenario.ctx());
        dashboard::issue_admin_cap(scenario.ctx());
        dashboard::new(otw, scenario.ctx());
    };

    scenario.next_tx(admin);
    {
        let mut dashboard = scenario.take_shared<Dashboard>();
        let admin_cap = scenario.take_from_sender<AdminCap>();
        let proposal_id = new_proposal(&admin_cap, scenario.ctx());

        dashboard.register_proposal(&admin_cap, proposal_id);
        let proposals_ids = dashboard.get_proposals_ids();
        let proposal_exists = proposals_ids.contains(&proposal_id);

        assert!(proposal_exists);

        scenario.return_to_sender(admin_cap);
        test_scenario::return_shared(dashboard);
    };

    scenario.end();
}

#[test]
fun test_voting() {
    let user1 = @0xB0B;
    let user2 = @0xB0C;
    let admin = @0xA01;

    let mut scenario = test_scenario::begin(admin);
    {
        dashboard::issue_admin_cap(scenario.ctx());
    };

    scenario.next_tx(admin);
    {
        let admin_cap = scenario.take_from_sender<AdminCap>();
        new_proposal(&admin_cap, scenario.ctx());
        test_scenario::return_to_sender(&scenario, admin_cap);
    };


    scenario.next_tx(user1);
    {
        let mut proposal = scenario.take_shared<Proposal>();
       
        let test_clock = set_time(10, scenario.ctx());
        
        proposal.vote(true, &test_clock, scenario.ctx());

        assert!(proposal.voted_yes_count() == 1, EWrongVoteCount);

        test_scenario::return_shared(proposal);

        test_clock.destroy_for_testing();
    };
    scenario.next_tx(user2);
    {
        let mut proposal = scenario.take_shared<Proposal>();
       
        let test_clock = set_time(10, scenario.ctx());

        proposal.vote(true, &test_clock, scenario.ctx());

        assert!(proposal.voted_yes_count() == 2, EWrongVoteCount);

        test_scenario::return_shared(proposal);
        test_clock.destroy_for_testing();
    };

    scenario.end();
}

#[test]
#[expected_failure(abort_code = proposal::EDuplicateVote)]
fun test_dublicate_voting() {
    let user1 = @0xB0B;
    let user2 = @0xB0C;
    let admin = @0xA01;

    let mut scenario = test_scenario::begin(admin);
    {
        dashboard::issue_admin_cap(scenario.ctx());
    };

    scenario.next_tx(admin);
    {
        let admin_cap = scenario.take_from_sender<AdminCap>();
        new_proposal(&admin_cap, scenario.ctx());
        test_scenario::return_to_sender(&scenario, admin_cap);
    };


    scenario.next_tx(user1);
    {
        let mut proposal = scenario.take_shared<Proposal>();
         let test_clock = set_time(10, scenario.ctx());

        proposal.vote(true, &test_clock, scenario.ctx());

        assert!(proposal.voted_yes_count() == 1, EWrongVoteCount);

        test_scenario::return_shared(proposal);
        test_clock.destroy_for_testing();
    };
    scenario.next_tx(user2);
    {
        let mut proposal = scenario.take_shared<Proposal>();
        let test_clock = set_time(10, scenario.ctx());

        proposal.vote(true, &test_clock, scenario.ctx());

        assert!(proposal.voted_yes_count() == 2, EWrongVoteCount);

        test_scenario::return_shared(proposal);
        test_clock.destroy_for_testing();
    };
      scenario.next_tx(user2);
      // this should fail because user2 has already voted
    {
        let mut proposal = scenario.take_shared<Proposal>();

        let test_clock = set_time(10, scenario.ctx());

        proposal.vote(true, &test_clock, scenario.ctx());

        test_scenario::return_shared(proposal);
        test_clock.destroy_for_testing();
    };

    scenario.end();
}

#[test]
fun test_issue_vote_proof() {
    let user1 = @0xB0B;
    let admin = @0xA01;

    let mut scenario = test_scenario::begin(admin);
    {
        dashboard::issue_admin_cap(scenario.ctx());
    };

    scenario.next_tx(admin);
    {
        let admin_cap = scenario.take_from_sender<AdminCap>();
        new_proposal(&admin_cap, scenario.ctx());
        test_scenario::return_to_sender(&scenario, admin_cap);
    };

     scenario.next_tx(user1);
    {
        let mut proposal = scenario.take_shared<Proposal>();

        let test_clock = set_time(10, scenario.ctx());

        proposal.vote(true, &test_clock, scenario.ctx());


        test_scenario::return_shared(proposal);
        test_clock.destroy_for_testing();
    };

    scenario.next_tx(user1);
    {
        let vote_proof = scenario.take_from_sender<VoteProofNFT>();

        assert!(vote_proof.vote_proof_url()== new_unsafe_from_bytes(b"https://thrangra.sirv.com/vote_yes_nft.jpg"));

       scenario.return_to_sender(vote_proof);
    };
  
     

    scenario.end();
}

#[test]
fun test_change_status() {
    let admin = @0xA01;

    let mut scenario = test_scenario::begin(admin);
    {
        dashboard::issue_admin_cap(scenario.ctx());
    };

    scenario.next_tx(admin);
    {
        let admin_cap = scenario.take_from_sender<AdminCap>();
        new_proposal(&admin_cap, scenario.ctx());
        test_scenario::return_to_sender(&scenario, admin_cap);
    };

    scenario.next_tx(admin);
    {
           let admin_cap = scenario.take_from_sender<AdminCap>();
            new_proposal(&admin_cap, scenario.ctx());
            test_scenario::return_to_sender(&scenario, admin_cap);
    };

    scenario.next_tx(admin);
    {
        let proposal = scenario.take_shared<Proposal>();
        assert!(proposal.is_active());
        test_scenario::return_shared(proposal);
    };   

    scenario.next_tx(admin);
    {
        let mut proposal = scenario.take_shared<Proposal>();
        let admin_cap = scenario.take_from_sender<AdminCap>();
        proposal.set_delisted_status(&admin_cap);
        assert!(!proposal.is_active(),EWrongStatus);
        test_scenario::return_to_sender(&scenario, admin_cap);
        test_scenario::return_shared(proposal);
    };
      scenario.next_tx(admin);
    {
        let mut proposal = scenario.take_shared<Proposal>();
        let admin_cap = scenario.take_from_sender<AdminCap>();
        proposal.set_active_status(&admin_cap);
        assert!(proposal.is_active(),EWrongStatus);
        test_scenario::return_to_sender(&scenario, admin_cap);
        test_scenario::return_shared(proposal);
    };

    scenario.end();
}

#[test]
#[expected_failure(abort_code = proposal::EProposalExpired)]
fun test_expired_proposal(){
    let user1 = @0xB0B;
    let admin = @0xA01;

    let mut scenario = test_scenario::begin(admin);
    {
        dashboard::issue_admin_cap(scenario.ctx());
    };

    scenario.next_tx(admin);
    {
        let admin_cap = scenario.take_from_sender<AdminCap>();
        new_proposal(&admin_cap, scenario.ctx());
        test_scenario::return_to_sender(&scenario, admin_cap);
    };

     scenario.next_tx(user1);
    {
        let mut proposal = scenario.take_shared<Proposal>();

        let test_clock = set_time(0, scenario.ctx());

        proposal.vote(true, &test_clock, scenario.ctx());


        test_scenario::return_shared(proposal);
        test_clock.destroy_for_testing();
    };

    scenario.end();
  
}

#[test]
#[expected_failure(abort_code = test_scenario::EEmptyInventory)]
fun test_remove_proposal(){
    let user1 = @0xB0B;
    let admin = @0xA01;

    let mut scenario = test_scenario::begin(admin);
    {
        dashboard::issue_admin_cap(scenario.ctx());
    };

    scenario.next_tx(admin);
    {
        let admin_cap = scenario.take_from_sender<AdminCap>();
        new_proposal(&admin_cap, scenario.ctx());
        scenario.return_to_sender(admin_cap);
    };

     scenario.next_tx(user1);
    {
        let mut proposal = scenario.take_shared<Proposal>();
        let test_clock = set_time(10, scenario.ctx());
        proposal.vote(true, &test_clock, scenario.ctx());
        test_scenario::return_shared(proposal);
        test_clock.destroy_for_testing();
    };

    scenario.next_tx(admin);
    {
        let  proposal = scenario.take_shared<Proposal>();
        let admin_cap = scenario.take_from_sender<AdminCap>();
        proposal.remove_proposal(&admin_cap);
        test_scenario::return_to_sender(&scenario, admin_cap);
    };
     scenario.next_tx(admin);
     // this should fail because the proposal is already removed
    {
        let  proposal = scenario.take_shared<Proposal>();
        test_scenario::return_shared(proposal);
    };

    scenario.end();
}
  

fun new_proposal(admin_cap: &AdminCap,ctx: &mut TxContext):ID{
    let title = b"Test".to_string();
    let description = b"Test".to_string();
    let proposal_id = proposal::create(admin_cap,title,description,TIME_TO_EXPIRE,ctx);
    proposal_id
}

fun set_time( time: u64, ctx: &mut TxContext): Clock{
      let mut test_clock = clock::create_for_testing(ctx);
    let test_time:u64 = TIME_TO_EXPIRE-time;
    test_clock.set_for_testing(test_time);
    test_clock
}
