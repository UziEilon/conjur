Feature: Azure Authenticator - Hosts can authenticate with Azure authenticator

  In this feature we define an Azure authenticator in policy, define different
  hosts and perform authentication with Conjur.

  Background:
    Given a policy:
    """
    - !policy
      id: conjur/authn-azure/prod
      body:
      - !webservice

      - !variable
        id: provider-uri

      - !group apps

      - !permit
        role: !group apps
        privilege: [ read, authenticate ]
        resource: !webservice
    """
    And I am the super-user
    And I successfully set Azure variables

  Scenario: Host with user-assigned-identity annotation is authorized
    And I have host "user-assigned-identity-app"
    And I set subscription-id annotation to host "user-assigned-identity-app"
    And I set resource-group annotation to host "user-assigned-identity-app"
    And I set user-assigned-identity annotation to host "user-assigned-identity-app"
    And I grant group "conjur/authn-azure/prod/apps" to host "user-assigned-identity-app"
    And I fetch a user-assigned Azure access token from inside machine
    When I authenticate via Azure with token as host "user-assigned-identity-app"
    Then host "user-assigned-identity-app" has been authorized by Conjur

  Scenario: Host without resource-group annotation is denied
    And I have host "no-resource-group-app"
    And I set subscription-id annotation to host "no-resource-group-app"
    And I grant group "conjur/authn-azure/prod/apps" to host "no-resource-group-app"
    And I fetch an Azure access token from inside machine
    And I save my place in the log file
    When I authenticate via Azure with token as host "no-resource-group-app"
    Then it is unauthorized
    And The following appears in the log after my savepoint:
    """
    Errors::Authentication::AuthnAzure::RoleMissingConstraint
    """

  Scenario: Host without subscription-id annotation is denied
    And I have host "no-subscription-id-app"
    And I set resource-group annotation to host "no-subscription-id-app"
    And I grant group "conjur/authn-azure/prod/apps" to host "no-subscription-id-app"
    And I fetch an Azure access token from inside machine
    And I save my place in the log file
    When I authenticate via Azure with token as host "no-subscription-id-app"
    Then it is unauthorized
    And The following appears in the log after my savepoint:
    """
    Errors::Authentication::AuthnAzure::RoleMissingConstraint
    """

  Scenario: Host without any Azure annotation is denied
    And I have host "no-azure-annotations-app"
    And I grant group "conjur/authn-azure/prod/apps" to host "no-azure-annotations-app"
    And I fetch an Azure access token from inside machine
    And I save my place in the log file
    When I authenticate via Azure with token as host "no-azure-annotations-app"
    Then it is unauthorized
    And The following appears in the log after my savepoint:
    """
    Errors::Authentication::AuthnAzure::RoleMissingConstraint
    """

  Scenario: Host with incorrect subscription-id Azure annotation is denied
    And I have host "incorrect-subscription-id-app"
    And I set resource-group annotation to host "incorrect-subscription-id-app"
    And I set subscription-id annotation with incorrect value to host "incorrect-subscription-id-app"
    And I grant group "conjur/authn-azure/prod/apps" to host "incorrect-subscription-id-app"
    And I fetch an Azure access token from inside machine
    And I save my place in the log file
    When I authenticate via Azure with token as host "incorrect-subscription-id-app"
    Then it is unauthorized
    And The following appears in the log after my savepoint:
    """
    Errors::Authentication::AuthnAzure::InvalidApplicationIdentity
    """

  Scenario: Host with incorrect resource-group Azure annotation is denied
    And I have host "incorrect-resource-group-app"
    And I set subscription-id annotation to host "incorrect-resource-group-app"
    And I set resource-group annotation with incorrect value to host "incorrect-resource-group-app"
    And I grant group "conjur/authn-azure/prod/apps" to host "incorrect-resource-group-app"
    And I fetch an Azure access token from inside machine
    And I save my place in the log file
    When I authenticate via Azure with token as host "incorrect-resource-group-app"
    Then it is unauthorized
    And The following appears in the log after my savepoint:
    """
    Errors::Authentication::AuthnAzure::InvalidApplicationIdentity
    """

  Scenario: Host with incorrect user-assigned-identity annotation is authorized
    And I have host "incorrect-user-assigned-identity-app"
    And I set subscription-id annotation to host "incorrect-user-assigned-identity-app"
    And I set resource-group annotation to host "incorrect-user-assigned-identity-app"
    And I set user-assigned-identity annotation with incorrect value to host "incorrect-user-assigned-identity-app"
    And I grant group "conjur/authn-azure/prod/apps" to host "incorrect-user-assigned-identity-app"
    And I fetch a user-assigned Azure access token from inside machine
    And I save my place in the log file
    When I authenticate via Azure with token as host "incorrect-user-assigned-identity-app"
    Then it is unauthorized
    And The following appears in the log after my savepoint:
    """
    Errors::Authentication::AuthnAzure::InvalidApplicationIdentity
    """

  Scenario: Non-existing host is denied
    And I fetch an Azure access token from inside machine
    And I save my place in the log file
    When I authenticate via Azure with token as host "non-existing-app"
    Then it is unauthorized
    And The following appears in the log after my savepoint:
    """
    Errors::Authentication::Security::RoleNotFound
    """

  Scenario: Host that is not in the permitted group is denied
    And I have host "non-permitted-app"
    And I set Azure annotations to host "non-permitted-app"
    And I fetch an Azure access token from inside machine
    And I save my place in the log file
    When I authenticate via Azure with token as host "non-permitted-app"
    Then it is forbidden
    And The following appears in the log after my savepoint:
    """
    Errors::Authentication::Security::RoleNotAuthorizedOnWebservice
    """