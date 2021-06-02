# frozen_string_literal: true

# Pagy initializer file (4.7.1)
# Customize only what you really need and notice that Pagy works also without any of the following lines.
# Should you just cherry pick part of this file, please maintain the require-order of the extras


# Pagy Variables
# See https://ddnexus.github.io/pagy/api/pagy#variables
# All the Pagy::VARS are set for all the Pagy instances but can be overridden
# per instance by just passing them to Pagy.new or the #pagy controller method


# Instance variables
# See https://ddnexus.github.io/pagy/api/pagy#instance-variables
Pagy::VARS[:page]   = 1                                  # default 
Pagy::VARS[:items]  = 2                               # default
Pagy::VARS[:outset] = 0                                  # default


# Other Variables
# See https://ddnexus.github.io/pagy/api/pagy#other-variables
# Pagy::VARS[:size]       = [1,4,4,1]                       # default
# Pagy::VARS[:page_param] = :page                           # default
# Pagy::VARS[:params]     = {}                              # default
# Pagy::VARS[:fragment]   = '#fragment'                     # example
# Pagy::VARS[:link_extra] = 'data-remote="true"'            # example
# Pagy::VARS[:i18n_key]   = 'pagy.item_name'                # default
# Pagy::VARS[:cycle]      = true                            # example


# Extras
# See https://ddnexus.github.io/pagy/extras
