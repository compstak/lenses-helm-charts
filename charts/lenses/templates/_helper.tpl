{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}

{{- define "metricTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_metrics_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_metrics
{{- end -}}
{{- end -}}

{{- define "auditTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_audits_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_audits
{{- end -}}
{{- end -}}

{{- define "processorTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_processors_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_processors
{{- end -}}
{{- end -}}

{{- define "alertTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_alerts_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_alerts
{{- end -}}
{{- end -}}

{{- define "profileTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_profiles_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_profiles
{{- end -}}
{{- end -}}

{{- define "alertSettingTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_alert_settings_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_alert_settings
{{- end -}}
{{- end -}}

{{- define "clusterTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_cluster_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_cluster
{{- end -}}
{{- end -}}

{{- define "lsqlTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_lsql_storage_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_lsql_storage
{{- end -}}
{{- end -}}

{{- define "metadataTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_topics_metadata_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_topics_metadata
{{- end -}}
{{- end -}}

{{- define "topologyTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
__topology_{{ .Values.lenses.topics.suffix }}
{{- else -}}
__topology
{{- end -}}
{{- end -}}

{{- define "externalMetricsTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
__topology__metrics_{{ .Values.lenses.topics.suffix }}
{{- else -}}
__topology__metrics
{{- end -}}
{{- end -}}

{{- define "connectorsTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_connectors_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_processors
{{- end -}}
{{- end -}}

{{- define "securityProtocol" -}}
{{- if and .Values.lenses.kafka.sasl.enabled .Values.lenses.kafka.ssl.enabled -}}
SASL_SSL
{{- end -}}
{{- if and .Values.lenses.kafka.sasl.enabled (not .Values.lenses.kafka.ssl.enabled) -}}
SASL_PLAINTEXT
{{- end -}}
{{- if and .Values.lenses.kafka.ssl.enabled (not .Values.lenses.kafka.sasl.enabled) -}}
SSL
{{- end -}}
{{- if and (not .Values.lenses.kafka.ssl.enabled) (not .Values.lenses.kafka.sasl.enabled) -}}
PLAINTEXT
{{- end -}}
{{- end -}}

{{- define "bootstrapBrokers" -}}
{{- $protocol := include "securityProtocol" . -}}
{{ range $index, $element := .Values.lenses.kafka.bootstrapServers }}
  {{- if $index -}}
    {{- if eq $protocol "PLAINTEXT" -}}
  ,{{$protocol}}://{{$element.name}}:{{$element.port}}
    {{- end -}}
    {{- if eq $protocol "SSL" -}}
  ,{{$protocol}}://{{$element.name}}:{{$element.sslPort}}
    {{- end -}}
    {{- if eq $protocol "SASL_SSL" -}}
  ,{{$protocol}}://{{$element.name}}:{{$element.saslSslPort}}
    {{- end -}}
    {{- if eq $protocol "SASL_PLAINTEXT" -}}
  ,{{$protocol}}://{{$element.name}}:{{$element.saslPlainTextPort}}
    {{- end -}}
  {{- else -}}
    {{- if eq $protocol "PLAINTEXT" -}}
  {{$protocol}}://{{$element.name}}:{{$element.port}}
    {{- end -}}
    {{- if eq $protocol "SSL" -}}
  {{$protocol}}://{{$element.name}}:{{$element.sslPort}}
    {{- end -}}
    {{- if eq $protocol "SASL_SSL" -}}
  {{$protocol}}://{{$element.name}}:{{$element.saslSslPort}}
    {{- end -}}
    {{- if eq $protocol "SASL_PLAINTEXT" -}}
  {{$protocol}}://{{$element.name}}:{{$element.saslPlainTextPort}}
    {{- end -}}
  {{- end -}}
  {{end}}
{{- end -}}

{{- define "kafkaMetrics" -}}
{{- if and .Values.lenses.kafka.metrics .Values.lenses.kafka.metrics.enabled -}}
{
  type: {{ default "JMX" .Values.lenses.kafka.metrics.type | quote}},
  ssl: {{ default false .Values.lenses.kafka.metrics.ssl}},
  {{- if .Values.lenses.kafka.metrics.username}}
  user: {{ .Values.lenses.kafka.metrics.username | quote}},
  {{- end }}
  {{- if .Values.lenses.kafka.metrics.password}}
  password: {{ .Values.lenses.kafka.metrics.password | quote}},
  {{- end }}
  {{- if .Values.lenses.kafka.metrics.ports}}
  port: [
    {{- if eq .Values.lenses.kafka.metrics.type "AWS" }}
    {{ range $index, $element := .Values.lenses.kafka.metrics.ports }}
    {{- if not $index -}}{id: {{$element.id}}, url: "{{$element.url}}"}
    {{- else}},
    {id: {{$element.id}}, url: "{{$element.url}}"}
    {{- end}}
    {{- end}}
    {{- else -}}
    {{ range $index, $element := .Values.lenses.kafka.metrics.ports }}
    {{- if not $index -}}{id: {{$element.id}}, port: {{$element.port}}, host: "{{$element.host}}"}
    {{- else}},
    {id: {{$element.id}}, port: {{$element.port}}, host: "{{$element.host}}"}
    {{- end}}
    {{- end}}
    {{- end }}
  ]
  {{- else}}
  default.port: {{ .Values.lenses.kafka.metrics.port }}
  {{- end}}
}
{{- end -}}
{{- end -}}

{{- define "kafkaSchemaBasicAuth" -}}
  {{- if .Values.lenses.schemaRegistries.security.enabled -}}
    {{- if (.Values.lenses.schemaRegistries.security.authType)  and eq .Values.lenses.schemaRegistries.security.authType "USER_INFO" -}}
    {{- .Values.lenses.schemaRegistries.security.username}}:{{.Values.lenses.schemaRegistries.security.password}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "jmxBrokers" -}}
[
  {{ range $index, $element := .Values.lenses.kafka.jmxBrokers }}
  {{- if not $index -}}{id: {{$element.id}}, port: {{$element.port}}}
  {{- else}},
  {id: {{$element.id}}, port: {{$element.port}}}
  {{- end}}
{{- end}}
]
{{- end -}}

{{- define "zookeepers" -}}
{{- if .Values.lenses.zookeepers.enabled -}}
[
  {{ range $index, $element := .Values.lenses.zookeepers.hosts }}
  {{- if not $index -}}{url: "{{$element.host}}:{{$element.port}}"
  {{- if $element.metrics -}}, metrics: {
    {{- if eq $element.metrics.type "JMX" -}}
    url: "{{$element.host}}:{{$element.metrics.port}}",
    {{- else }}
    url: "{{$element.protocol}}://{{$element.host}}:{{$element.metrics.port}}",
    {{- end }}
    type: "{{$element.metrics.type}}",
    ssl: {{default false $element.metrics.ssl}},
    {{- if $element.metrics.username -}}
    user: {{$element.metrics.username | quote}},
    {{- end }}
    {{- if $element.metrics.password -}}
    password: {{$element.metrics.password | quote}},
    {{- end }}
  }{{- end}}}
  {{- else}},
  {url: "{{$element.host}}:{{$element.port}}"
  {{- if $element.metrics -}}, metrics: {
    {{- if eq $element.metrics.type "JMX" -}}
    url: "{{$element.host}}:{{$element.metrics.port}}",
    {{- else }}
    url: "{{$element.protocol}}://{{$element.host}}:{{$element.metrics.port}}",
    {{- end }}
    type: "{{default "JMX" $element.metrics.type}}",
    ssl: {{default false $element.ssl}},
    {{- if $element.metrics.username -}}
    user: {{$element.metrics.username | quote}},
    {{- end }}
    {{- if $element.metrics.password -}}
    password: {{$element.metrics.password | quote}}
    {{- end }}
  }{{- end}}}
  {{- end}}
{{- end}}
]
{{- end -}}
{{- end -}}

{{- define "registries" -}}
{{- if .Values.lenses.schemaRegistries.enabled -}}
[
  {{ range $index, $element := .Values.lenses.schemaRegistries.hosts }}
  {{- if not $index -}}{url: "{{$element.protocol}}://{{$element.host}}:{{$element.port}}{{$element.path}}"
  {{- if $element.metrics -}}, metrics: {
    {{- if eq $element.metrics.type "JMX" -}}
    url: "{{$element.host}}:{{$element.metrics.port}}",
    {{- else }}
    url: "{{$element.protocol}}://{{$element.host}}:{{$element.metrics.port}}",
    {{- end }}
    type: "{{default "JMX" $element.metrics.type}}",
    ssl: {{default false $element.metrics.ssl}}
    {{- if $element.metrics.username -}},
    user: {{$element.metrics.username | quote}},
    {{- end }}
    {{- if $element.metrics.password -}}
    password: {{$element.metrics.password | quote}}
    {{- end }}
  }{{- end}}}
  {{- else}},
  {url: "{{$element.protocol}}://{{$element.host}}:{{$element.port}}"
  {{- if $element.metrics -}}, metrics: {
    {{- if eq $element.metrics.type "JMX" -}}
    url: "{{$element.host}}:{{$element.metrics.port}}",
    {{- else }}
    url: "{{$element.protocol}}://{{$element.host}}:{{$element.metrics.port}}",
    {{- end }}
    type: "{{default "JMX" $element.metrics.type}}",
    ssl: {{default false $element.ssl}}
    {{- if $element.metrics.username -}},
    user: {{$element.metrics.username | quote}},
    {{- end }}
    {{- if $element.metrics.password -}}
    password: {{$element.metrics.password | quote}}
    {{- end }}
  }{{- end}}}
  {{- end}}
{{- end}}
]
{{- end -}}
{{- end -}}


{{- define "connect" -}}
{{- if .Values.lenses.connectClusters.enabled -}}
[
{{- range $index, $element := .Values.lenses.connectClusters.clusters -}}
  {{- $port := index $element "port" -}}
  {{- $protocol := index $element "protocol" -}}
  {{- if not $index -}}{
    name: "{{- index $element "name"}}",
    statuses: "{{index $element "statusTopic"}}",
    configs: "{{index $element "configTopic"}}",
    offsets: "{{index $element "offsetsTopic"}}",
    {{ if index $element "authType" }}auth: "{{index $element "authType"}}",{{- end -}}
    {{ if index $element "username" }}username: "{{index $element "username"}}",{{- end -}}
    {{ if index $element "password" }}password: "{{index $element "password"}}",{{- end -}}
    urls: [
      {{ range $index, $element := index $element "hosts" -}}
        {{- if not $index -}}
        {url: "{{$protocol}}://{{$element.host}}:{{$port}}"
        {{- if $element.metrics -}}, metrics: {
        {{- if eq $element.metrics.type "JMX" -}}
        url: "{{$element.host}}:{{$element.metrics.port}}",
        {{- else }}
        url: "{{$protocol}}://{{$element.host}}:{{$element.metrics.port}}",
        {{- end }}
          type: "{{default "JMX" $element.metrics.type}}",
          ssl: {{default false $element.metrics.ssl}},
          {{- if $element.metrics.username -}}
          user: {{$element.metrics.username | quote}},
          {{- end }}
          {{- if $element.metrics.password -}}
          password: {{$element.metrics.password | quote}}
          {{- end }}
        }{{- end}}}
        {{- else -}},
        {url: "{{$protocol}}://{{$element.host}}:{{$port}}"
        {{- if $element.metrics -}}, metrics: {
        {{- if eq $element.metrics.type "JMX" -}}
        url: "{{$element.host}}:{{$element.metrics.port}}",
        {{- else }}
        url: "{{$protocol}}://{{$element.host}}:{{$element.metrics.port}}",
        {{- end }}
          type: "{{default "JMX" $element.metrics.type}}",
          ssl: {{default false $element.metrics.ssl}},
          {{- if $element.metrics.username -}}
          user: {{$element.metrics.username | quote}},
          {{- end }}
          {{- if $element.metrics.password -}}
          password: {{$element.metrics.password | quote}}
          {{- end }}
        }{{- end}}}
        {{- end -}}
      {{- end}}
    ]
  }
  {{- else}},
  {
    name: "{{- index $element "name"}}",
    statuses: "{{index $element "statusTopic"}}",
    configs: "{{index $element "configTopic"}}",
    offsets: "{{index $element "offsetsTopic"}}",
    {{ if index $element "authType" }}authType: "{{index $element "authType"}}",{{- end -}}
    {{ if index $element "username" }}username: "{{index $element "username"}}",{{- end -}}
    {{ if index $element "password" }}password: "{{index $element "password"}}",{{- end -}}
    urls:[
      {{ range $index, $element := index $element "hosts" -}}
        {{- if not $index -}}
        {url: "{{$protocol}}://{{$element.host}}:{{$port}}"
        {{- if $element.metrics -}}, metrics: {
        {{- if eq $element.metrics.type "JMX" -}}
        url: "{{$element.host}}:{{$element.metrics.port}}",
        {{- else }}
        url: "{{$protocol}}://{{$element.host}}:{{$element.metrics.port}}",
        {{- end }}
          type: "{{default "JMX" $element.metrics.type}}",
          ssl: {{default false $element.metrics.ssl}},
          {{- if $element.metrics.username -}}
          user: {{$element.metrics.username | quote}},
          {{- end }}
          {{- if $element.metrics.password -}}
          password: {{$element.metrics.password | quote}}
          {{- end }}
        }{{- end}}}
        {{- else -}},
        {url: "{{$protocol}}://{{$element.host}}:{{$port}}"
        {{- if $element.metrics -}}, metrics: {
        {{- if eq $element.metrics.type "JMX" -}}
        url: "{{$element.host}}:{{$element.metrics.port}}",
        {{- else }}
        url: "{{$protocol}}://{{$element.host}}:{{$element.metrics.port}}",
        {{- end }}
          type: "{{default "JMX" $element.metrics.type}}",
          ssl: {{default false $element.metrics.ssl}},
          {{- if $element.metrics.username -}}
          user: {{$element.metrics.username | quote}},
          {{- end }}
          {{- if $element.metrics.password -}}
          password: {{$element.metrics.password | quote}}
          {{- end }}
        }{{- end}}}
        {{- end -}}
      {{- end}}
    ]
  }
  {{- end}}
{{- end}}
]
{{- end -}}
{{- end -}}


{{- define "alertPlugins" -}}
{{- if .Values.lenses.alerts.plugins -}}
[
  {{ range $index, $element := .Values.lenses.alerts.plugins }}
  {{- if not $index -}}{class: "{{$element.class}}", config: {{$element.config}}}
  {{- else}},{class: "{{$element.class}}", config: {{$element.config}}}{{- end }}
  {{- end }}
]
{{- end -}}
{{- end -}}

{{- define "kerberos" -}}
{{- if .Values.lenses.security.kerberos.enabled }}
lenses.security.kerberos.service.principal={{ .Values.lenses.security.kerberos.servicePrincipal | quote }}
lenses.security.kerberos.keytab=/mnt/secrets/lenses.keytab
lenses.security.kerberos.debug={{ .Values.lenses.security.kerberos.debug | quote }}
{{end -}}
{{- end -}}

{{- define "lensesAppendConf" -}}
{{ default "" .Values.lenses.append.conf }}
{{- end -}}

{{- define "securityConf" -}}
{{- if .Values.lenses.security.defaultUser -}}
lenses.security.user={{ .Values.lenses.security.defaultUser.username | quote }}
lenses.security.password={{ .Values.lenses.security.defaultUser.password | quote }}
{{- end -}}
{{- if .Values.lenses.security.ldap.enabled }}
lenses.security.ldap.url={{ .Values.lenses.security.ldap.url | quote }}
lenses.security.ldap.base={{ .Values.lenses.security.ldap.base | quote }}
lenses.security.ldap.user={{ .Values.lenses.security.ldap.user | quote }}
lenses.security.ldap.password={{ .Values.lenses.security.ldap.password | quote }}
lenses.security.ldap.filter={{ .Values.lenses.security.ldap.filter | quote }}
lenses.security.ldap.plugin.class={{ .Values.lenses.security.ldap.plugin.class | quote }}
lenses.security.ldap.plugin.memberof.key={{ .Values.lenses.security.ldap.plugin.memberofKey | quote }}
lenses.security.ldap.plugin.group.extract.regex={{ .Values.lenses.security.ldap.plugin.groupExtractRegex | quote }}
lenses.security.ldap.plugin.person.name.key={{ .Values.lenses.security.ldap.plugin.personNameKey | quote }}
{{- end -}}
{{- if .Values.lenses.security.saml.enabled }}
lenses.security.saml.base.url={{ .Values.lenses.security.saml.baseUrl | quote }}
lenses.security.saml.idp.provider={{ .Values.lenses.security.saml.provider | quote }}
lenses.security.saml.idp.metadata.file="/mnt/secrets/saml.idp.xml"
lenses.security.saml.keystore.location="/mnt/secrets/saml.keystore.jks"
lenses.security.saml.keystore.password={{ .Values.lenses.security.saml.keyStorePassword | quote }}
{{- if .Values.lenses.security.saml.keyAlias }}
lenses.security.saml.key.alias={{ .Values.lenses.security.saml.keyAlias | quote }}
{{- end }}
lenses.security.saml.key.password={{ .Values.lenses.security.saml.keyPassword | quote }}
{{- end }}
{{- if .Values.lenses.security.kerberos.enabled -}}
{{ include "kerberos" .}}
{{- end -}}
{{- end -}}
