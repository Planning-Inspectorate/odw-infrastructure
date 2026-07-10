# common variables loaded by default
# see https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files

odt_appeals_back_office_sb_topic_subscriptions = [
  {
    subscription_name = "appeal-has-odw-sub"
    topic_name        = "appeal-has"
  },
  {
    subscription_name = "appeal-s78-odw-sub"
    topic_name        = "appeal-s78"
  },
  {
    subscription_name = "appeal-document-odw-sub"
    topic_name        = "appeal-document"
  },
  {
    subscription_name = "appeal-event-odw-sub"
    topic_name        = "appeal-event"
  },
  {
    subscription_name = "appeal-service-user-odw-sub"
    topic_name        = "appeal-service-user"
  },
  {
    subscription_name = "appeal-representation-odw-sub"
    topic_name        = "appeal-representation"
  },
  {
    subscription_name = "appeal-event-estimate-odw-sub"
    topic_name        = "appeal-event-estimate"
  },
  {
    subscription_name = "appeal-document-odw-wake-sub"
    topic_name        = "appeal-document"
  },
  {
    subscription_name = "appeal-document-to-move-bo-sub"
    topic_name        = "appeal-document-to-move"
  },
  {
    subscription_name = "appeal-event-odw-wake-sub"
    topic_name        = "appeal-event"
  },
  {
    subscription_name = "appeal-event-estimate-odw-wake-sub"
    topic_name        = "appeal-event-estimate"
  },
  {
    subscription_name = "appeal-has-odw-wake-sub"
    topic_name        = "appeal-has"
  },
  {
    subscription_name = "appeal-representation-odw-wake-sub"
    topic_name        = "appeal-representation"
  },
  {
    subscription_name = "appeal-s78-odw-wake-sub"
    topic_name        = "appeal-s78"
  },
  {
    subscription_name = "appeal-service-user-odw-wake-sub"
    topic_name        = "appeal-service-user"
  }
]

tooling_config = {
  network_name    = "pins-vnet-shared-tooling-uks"
  network_rg      = "pins-rg-shared-tooling-uks"
  subscription_id = "edb1ff78-90da-4901-a497-7e79f966f8e2"
}

odt_backoffice_sb_topic_subscriptions_to_import = [
  {
    subscription_name = "folder-odw-wake-sub"
    topic_name        = "folder"
  },
  {
    subscription_name = "odw-nsip-document-wake-sub"
    topic_name        = "nsip-document"
  },
  {
    subscription_name = "odw-nsip-exam-timetable-wake-sub"
    topic_name        = "nsip-exam-timetable"
  },
  {
    subscription_name = "odw-nsip-project-wake-sub"
    topic_name        = "nsip-project"
  },
  {
    subscription_name = "odw-nsip-project-update-wake-sub"
    topic_name        = "nsip-project-update"
  },
  {
    subscription_name = "odw-nsip-representation-wake-sub"
    topic_name        = "nsip-representation"
  },
  {
    subscription_name = "odw-nsip-s51-advice-wake-sub"
    topic_name        = "nsip-s51-advice"
  },
  {
    subscription_name = "odw-nsip-subscription-wake-sub"
    topic_name        = "nsip-subscription"
  },
  {
    subscription_name = "odw-service-user-wake-sub"
    topic_name        = "service-user"
  }
]

odt_appeals_backoffice_sb_topic_subscriptions_to_import = [
  {
    subscription_name = "appeal-document-odw-wake-sub"
    topic_name        = "appeal-document"
  },
  {
    subscription_name = "appeal-document-to-move-bo-sub"
    topic_name        = "appeal-document-to-move"
  },
  {
    subscription_name = "appeal-event-odw-wake-sub"
    topic_name        = "appeal-event"
  },
  {
    subscription_name = "appeal-event-estimate-odw-wake-sub"
    topic_name        = "appeal-event-estimate"
  },
  {
    subscription_name = "appeal-has-odw-wake-sub"
    topic_name        = "appeal-has"
  },
  {
    subscription_name = "appeal-representation-odw-wake-sub"
    topic_name        = "appeal-representation"
  },
  {
    subscription_name = "appeal-s78-odw-wake-sub"
    topic_name        = "appeal-s78"
  },
  {
    subscription_name = "appeal-service-user-odw-wake-sub"
    topic_name        = "appeal-service-user"
  }
]