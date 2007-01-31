my $sub = sub {
	use warnings;
	use strict 'refs';
	my($self, $instance, $c) = @_;
	return {'owner', $c->user};
};

my $VAR1 = {
			clear_user => $sub,
			workflow=> {
          'initial_state' => 'new',
          'states' => {
                        'closed' => undef,
                        'awaiting_approval' => {
                                                 'transitions' => [
                                                                    {
                                                                      'name' => 'resolved',
                                                                      'to_state' => 'closed'
                                                                    },
                                                                    {
                                                                      'name' => 'unresolved',
                                                                      'to_state' => 'open'
                                                                    }
                                                                  ]
                                               },
                        'open' => {
                                    'transitions' => [
                                                       {
                                                         'set_fields' => {
                                                                           'owner' => undef
                                                                         },
                                                         'name' => 'reassign',
                                                         'to_state' => 'unassigned'
                                                       },
                                                       {
                                                         'name' => 'claim_fixed',
                                                         'to_state' => 'awaiting_approval'
                                                       }
                                                     ]
                                  },
                        'rejected' => undef,
                        'unassigned' => {
                                          'transitions' => [
                                                             {
                                                               'body' => $sub,
															   'body_sets_fields' => 'yes',
                                                               'name' => 'take',
                                                               'to_state' => 'open'
                                                             }
                                                           ]
                                        },
                        'new' => {
                                   'transitions' => [
                                                      {
                                                        'name' => 'reject',
                                                        'to_state' => 'rejected'
                                                      },
                                                      'accept'
                                                    ]
                                 }
                      },
          'transitions' => [
                             {
                               'body' => $sub,
							   'body_sets_fields' => 'yes',
                               'name' => 'accept',
                               'to_state' => 'open'
                             }
                           ]
        },
	};

use YAML;

$YAML::UseCode = 1;

print YAML::Dump( $VAR1 );
