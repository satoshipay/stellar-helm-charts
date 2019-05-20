{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "stellar-core.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "stellar-core.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "stellar-core.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "stellar-core.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "stellar-core.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "stellar-core.postgresql.fullname" -}}
{{- if .Values.postgresql.fullnameOverride -}}
{{- .Values.postgresql.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "stellar-core.env" -}}
{{- with .Values.existingNodeSeedSecret }}
- name: NODE_SEED
  valueFrom:
    secretKeyRef:
      name: {{ required "name of existingNodeSeedSecret is required" .name | quote }}
      key: {{ required "key of existingNodeSeedSecret is required" .key | quote }}
{{- else }}
- name: NODE_SEED
  valueFrom:
    secretKeyRef:
      name: {{ template "stellar-core.fullname" . }}
      key: nodeSeed
{{- end }}
{{- if .Values.postgresql.enabled }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "stellar-core.postgresql.fullname" . }}
      key: postgresql-password
- name: DATABASE
  value: postgresql://dbname={{ .Values.postgresql.postgresqlDatabase }} user={{ .Values.postgresql.postgresqlUsername }} password=$(DATABASE_PASSWORD) host={{ template "stellar-core.postgresql.fullname" . }} connect_timeout={{ .Values.postgresqlConnectTimeout }}
{{- else }}
{{- with .Values.existingDatabase.passwordSecret }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .name | quote }}
      key: {{ .key | quote }}
{{- end }}
- name: DATABASE
  value: {{ .Values.existingDatabase.url }}
{{- end }}
- name: INITIALIZE_DB
  value: {{ .Values.initializeDatabase | quote }}
{{- with .Values.knownPeers }}
- name: KNOWN_PEERS
  value: "{{ join "," .}}"
{{- end }}
{{- with .Values.preferredPeerKeys }}
- name: PREFERRED_PEER_KEYS
  value: "{{ join "," .}}"
{{- end }}
{{- with .Values.preferredPeers }}
- name: PREFERRED_PEERS
  value: "{{ join "," .}}"
{{- end }}
{{- with .Values.nodeNames }}
- name: NODE_NAMES
  value: "{{range $index, $element := . }}{{ if gt $index 0 }},{{ end }}{{ $element.publicKey }} {{ $element.name }}{{ end }}"
{{- end }}
{{- with .Values.knownCursors }}
- name: KNOWN_CURSORS
  value: "{{ join "," .}}"
{{- end }}
{{- if .Values.unsafeQuorum }}
- name: UNSAFE_QUORUM
  value: "true"
{{- end }}
{{- with .Values.quorumSet }}
- name: QUORUM_SET
  value: {{ . | toJson | quote }}
{{- end }}
{{- with .Values.history }}
- name: HISTORY
  value: {{ . | toJson | quote }}
{{- end }}
- name: INITIALIZE_HISTORY_ARCHIVES
  value: {{ .Values.initializeHistoryArchives | quote }}
{{- if .Values.gcloudServiceAccountKey }}
- name: GCLOUD_SERVICE_ACCOUNT_KEY
  valueFrom:
    secretKeyRef:
      name: {{ template "stellar-core.fullname" . }}
      key: gcloudServiceAccountKey
{{- end }}
{{- with .Values.nodeIsValidator }}
- name: NODE_IS_VALIDATOR
  value: {{ . | quote }}
{{- end }}
{{- with .Values.networkPassphrase }}
- name: NETWORK_PASSPHRASE
  value: {{ . | quote }}
{{- end }}
{{- with .Values.catchupComplete }}
- name: CATCHUP_COMPLETE
  value: {{ . | quote }}
{{- end }}
{{- with .Values.catchupRecent }}
- name: CATCHUP_RECENT
  value: {{ . | quote }}
{{- end }}
{{- with .Values.targetPeerConnections }}
- name: TARGET_PEER_CONNECTIONS
  value: {{ . | quote }}
{{- end }}
{{- with .Values.maxAdditionalPeerConnections }}
- name: MAX_ADDITIONAL_PEER_CONNECTIONS
  value: {{ . | quote }}
{{- end }}
{{- with .Values.maxPendingConnections }}
- name: MAX_PENDING_CONNECTIONS
  value: {{ . | quote }}
{{- end }}
{{- with .Values.maxConcurrentSubprocesses }}
- name: MAX_CONCURRENT_SUBPROCESSES
  value: {{ . | quote }}
{{- end }}
{{- range $key, $val := .Values.environment }}
- name: {{ $key }}
  value: {{ $val | quote }}
{{- end }}
{{- end -}}
