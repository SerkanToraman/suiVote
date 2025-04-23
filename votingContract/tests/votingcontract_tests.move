
#[test_only]
module votingcontract::votingcontract_tests;
// uncomment this line to import the module
use sui::test_scenario;
use votingcontract::dashboard::{Self,AdminCap,Dashboard};
use votingcontract::proposal::{Self,Proposal};


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
        let created_proposal = scenario.take_from_sender<Proposal>();
        assert!(created_proposal.title()==b"Test".to_string());
        assert!(created_proposal.description()==b"Test".to_string());
        assert!(created_proposal.expiration()==2000000000);
        assert!(created_proposal.creator()==user);
        assert!(created_proposal.voted_yes_count()==0);
        assert!(created_proposal.voted_no_count()==0);
        assert!(created_proposal.voting_registry().is_empty());
        
        test_scenario::return_to_sender(&scenario,created_proposal);

    };
    scenario.end();
}


fun new_proposal(admin_cap: &AdminCap,ctx: &mut TxContext):ID{
    let title = b"Test".to_string();
    let description = b"Test".to_string();
    let proposal_id = proposal::create(admin_cap,title,description,2000000000,ctx);
    proposal_id
}
