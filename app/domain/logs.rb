# frozen_string_literal: true

require 'util/trackable_log_message_class'

unless defined? LogMessages::Authentication::OriginValidated
  # This wrapper prevents classes from being loaded by Rails
  # auto-load. #TODO: fix this in a proper manner

  module LogMessages

    module Authentication

      OriginValidated = ::Util::TrackableLogMessageClass.new(
        msg:  "Origin validated",
        code: "CONJ00003D"
      )

      ValidatingAnnotationsWithPrefix = ::Util::TrackableLogMessageClass.new(
        msg:  "Validating annotations with prefix {0-prefix}",
        code: "CONJ00025D"
      )

      RetrievedAnnotationValue = ::Util::TrackableLogMessageClass.new(
        msg:  "Retrieved value of annotation {0-annotation-name}",
        code: "CONJ00024D"
      )

      module Security

        SecurityValidated = ::Util::TrackableLogMessageClass.new(
          msg:  "Security validated",
          code: "CONJ00001D"
        )

      end

      module OAuth

        IdentityProviderUri = ::Util::TrackableLogMessageClass.new(
          msg:  "Working with Identity Provider {0-provider-uri}",
          code: "CONJ00007D"
        )

        IdentityProviderDiscoverySuccess = ::Util::TrackableLogMessageClass.new(
          msg:  "Identity Provider discovery succeeded",
          code: "CONJ00008D"
        )

        FetchProviderKeysSuccess = ::Util::TrackableLogMessageClass.new(
          msg:  "Fetched Identity Provider keys successfully",
          code: "CONJ00009D"
        )

        ValidateProviderKeysAreUpdated = ::Util::TrackableLogMessageClass.new(
          msg:  "Validating that Identity Provider keys are up to date",
          code: "CONJ00019D"
        )

      end

      module Jwt

        TokenDecodeSuccess = ::Util::TrackableLogMessageClass.new(
          msg:  "Token decoded successfully",
          code: "CONJ00005D"
        )

        TokenDecodeFailed = ::Util::TrackableLogMessageClass.new(
          msg:  "Failed to decode the token with the error '{0-exception}'",
          code: "CONJ00018D"
        )

      end

      module AuthnOidc

        ExtractedUsernameFromIDToked = ::Util::TrackableLogMessageClass.new(
          msg:  "Extracted username '{0}' from ID token field '{1-id-token-username-field}'",
          code: "CONJ00004D"
        )

      end

      module AuthnK8s

        PodChannelOpen = ::Util::TrackableLogMessageClass.new(
          msg:  "Pod '{0-pod-name}' : channel open",
          code: "CONJ00010D"
        )

        PodChannelClosed = ::Util::TrackableLogMessageClass.new(
          msg:  "Pod '{0-pod-name}' : channel closed",
          code: "CONJ00011D"
        )

        PodChannelData = ::Util::TrackableLogMessageClass.new(
          msg:  "Pod '{0-pod-name}', channel '{1-cahnnel-name}': {2-message-data}",
          code: "CONJ00012D"
        )

        PodMessageData = ::Util::TrackableLogMessageClass.new(
          msg:  "Pod: '{0-pod-name}', message: '{1-message-type}', data: '{2-message-data}'",
          code: "CONJ00013D"
        )

        PodError = ::Util::TrackableLogMessageClass.new(
          msg:  "Pod '{0-pod-name}' error : '{1}'",
          code: "CONJ00014D"
        )

        CopySSLToPod = ::Util::TrackableLogMessageClass.new(
          msg:  "Copying SSL certificate to {0-pod-namespace}/{1-pod-name}",
          code: "CONJ00015D"
        )

        ValidatingHostId = ::Util::TrackableLogMessageClass.new(
          msg:  "Validating host id {0}",
          code: "CONJ00026D"
        )

        HostIdFromCommonName = ::Util::TrackableLogMessageClass.new(
          msg:  "Host id {0} extracted from CSR common name",
          code: "CONJ00027D"
        )

        SetCommonName = ::Util::TrackableLogMessageClass.new(
          msg:  "Setting common name to {0-full-host-name}",
          code: "CONJ00028D"
        )
      end
    end

    module Util

      RateLimitedCacheUpdated = ::Util::TrackableLogMessageClass.new(
        msg:  "Rate limited cache updated successfully",
        code: "CONJ00016D"
      )

      RateLimitedCacheLimitReached = ::Util::TrackableLogMessageClass.new(
        msg:  "Rate limited cache reached the '{0-limit}' limit and will not" \
              "call target for the next '{1-seconds}' seconds",
        code: "CONJ00020D"
      )

      ConcurrencyLimitedCacheUpdated = ::Util::TrackableLogMessageClass.new(
        msg:  "Concurrency limited cache updated successfully",
        code: "CONJ00021D"
      )

      ConcurrencyLimitedCacheReached = ::Util::TrackableLogMessageClass.new(
        msg:  "Concurrency limited cache reached the '{0-limit}' limit and will not call target",
        code: "CONJ00022D"
      )

      ConcurrencyLimitedCacheConcurrentRequestsUpdated = ::Util::TrackableLogMessageClass.new(
        msg:  "Concurrency limited cache concurrent requests updated to '{0-concurrent-requests}'",
        code: "CONJ00023D"
      )

    end
  end
end
