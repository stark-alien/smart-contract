use starknet::ContractAddress;

#[starknet::interface]
trait IGovernance<TContractState> {
    fn vote(ref self: TContractState, vote: felt252);
    fn get_voted(self: @TContractState, address: ContractAddress) -> felt252;
    fn amount_yes(self: @TContractState) -> u256;
    fn amount_no(self: @TContractState) -> u256;
}


#[starknet::contract]
mod StarkAlienGovernance {
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        voted_list: LegacyMap::<ContractAddress, felt252>,
        yes: u256,
        no: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {}

    #[abi(embed_v0)]
    impl Governance of super::IGovernance<ContractState> {
        fn vote(ref self: ContractState, vote: felt252) {
            assert(vote == 'yes' || vote == 'no', 'Wrong input');
            let voted = self.get_voted(get_caller_address());
            assert(voted != vote, 'You voted');
            let is_yes = vote == 'yes';
            let is_voted = voted != 0;

            if is_yes {
                self.yes.write(self.amount_yes() + 1);
                if is_voted {
                    self.no.write(self.amount_no() - 1);
                }
            } else {
                self.no.write(self.amount_no() + 1);
                if is_voted {
                    self.yes.write(self.amount_yes() - 1);
                }
            }

            self.voted_list.write(get_caller_address(), vote);
        }

        fn get_voted(self: @ContractState, address: ContractAddress) -> felt252 {
            self.voted_list.read(address)
        }

        fn amount_yes(self: @ContractState) -> u256 {
            self.yes.read()
        }

        fn amount_no(self: @ContractState) -> u256 {
            self.no.read()
        }
    }
}
