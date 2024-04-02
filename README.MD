Lately I have been testing and implementing Elastic’s Curator tool to manage storage space in an Elastic cluster. Curator is an awesome tool to automate the tedious task of manually managing old indices in Elasticsearch.

I am using Curator to delete indices once the index has reached a certain age or a disk space limit has been reached. Curator has other actions that can be taken such as snapshots, rollover and many others, which can been seen here. Before writing and testing any rules in your environment, be certain to configure Curator using a configuration file. In this file, you will input settings for accessing your Elasticsearch cluster, authentication and logging. More information on the Curator configuration file can be found here.

An important thing to remember when running and testing Curator, is to use the dry run option at first. Using this option will log any action that your Curator role would have taken. This will allow you to confirm your rule is behaving as expected and you do not accidentally delete data from your cluster that you did not mean to.

curator /path/to/rule --dry-run --config /path/to/config 

A list of curator rules that I have written and tested can be found on my GitHub. The first rule that I will walk through, and likely the simplest rule to begin with, is to delete indices after they have reached a certain age. This rule uses 2 filters, pattern and age, and 1 action, delete indices. This rule can be found here or in the code-block below.

This rule can be a very easy solution to following policies for data retention. If you have different time frames for how long you must retain data, possibly different depending on the data source, you can modify this rule to fit each data source you have. For example, if I am required to retain firewall logs for 90 days, I can change the jaeger pattern to match the index which contains these logs, and only delete data in that specific index. This will help you meet data retention policies agreed upon within your organization or that you must legally follow.
```
---
actions:
  1:
    action: delete_indices
    description: >-
      Delete indices older than 6 months (based on index name), for jaeger-* prefixed indices. Ignore the error if the filter does not result in an actionable list of indices (ignore_empty_list) and exit cleanly.
    options:
      ignore_empty_list: True
      timeout_override:
      continue_if_exception: False
      disable_action: False
    filters:
    - filtertype: pattern
      kind: prefix
      value: jaeger-*-
      exclude:
    - filtertype: age
      source: name
      direction: older
      timestring: ‘%Y-%m-%d’
      unit: months
      unit_count: 6
      exclude:
```
The second rule that I will be covering is based on used disk space in the cluster. This rule uses 2 filters, pattern and space, and 1 action, delete indices. This rule can be found here or in the code-block shown below. In this rule, you can assume that my cluster has 1TB of space, the disk_space value is measure in GB by default. Once my cluster has reached 800 GB of space used, Curator will delete the oldest indices until my cluster returns under the 800 GB threshold.
```

---
actions:
  1:
    action: delete_indices
    description: >-
      Delete indices when the cluster desk space has exceeded 80% (800 GB) usage, for jaeger-* prefixed indices. Ignore the error if the filter does not result in an actionable list of indices (ignore_empty_list) and exit cleanly.
    options:
      ignore_empty_list: True
      timeout_override:
      continue_if_exception: False
      disable_action: False
    filters:
    - filtertype: pattern
      kind: prefix
      value: jaeger-
      exclude:
    - filtertype: space
      disk_space: 800
      use_age: True
      source: creation_date
```

Curator is a powerful tool, that with the proper rules and automation, can save you a lot of time and frustration when dealing with Elastic indices and cluster space. For any further information on Curator, please refer to Elastic’s official documentation. Please comment with any questions, suggestions, or anything else!