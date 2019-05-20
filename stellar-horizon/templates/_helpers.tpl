{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "stellar-horizon.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "stellar-horizon.fullname" -}}
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
{{- define "stellar-horizon.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "stellar-horizon.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "stellar-horizon.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "stellar-horizon.postgresql.fullname" -}}
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

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "stellar-horizon.stellar-core.fullname" -}}
{{- $stellarCore := index .Values "stellar-core" -}}
{{- if $stellarCore.fullnameOverride -}}
{{- $stellarCore.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "stellar-core" $stellarCore.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "stellar-horizon.stellar-core.postgresql.fullname" -}}
{{- $postgresql := index .Values "stellar-core" "postgresql" -}}
{{- if $postgresql.fullnameOverride -}}
{{- $postgresql.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "postgresql" $postgresql.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "stellar-horizon.env" -}}
{{- if .Values.postgresql.enabled }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "stellar-horizon.postgresql.fullname" . }}
      key: postgresql-password
- name: DATABASE_URL
  value: postgres://{{ .Values.postgresql.postgresqlUsername }}:$(DATABASE_PASSWORD)@{{ template "stellar-horizon.postgresql.fullname" . }}/{{ .Values.postgresql.postgresqlDatabase }}?sslmode=disable
{{- else }}
{{- with .Values.existingDatabase.passwordSecret }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .name | quote }}
      key: {{ .key | quote }}
{{- end }}
- name: DATABASE_URL
  value: {{ .Values.existingDatabase.url }}
{{- end }}
{{- if index .Values "stellar-core" "enabled" }}
- name: STELLAR_CORE_URL
  value: http://{{ template "stellar-horizon.stellar-core.fullname" . }}-http:11626
- name: STELLAR_CORE_DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "stellar-horizon.stellar-core.postgresql.fullname" . }}
      key: postgresql-password
- name: STELLAR_CORE_DATABASE_URL
  value: postgres://postgres:$(STELLAR_CORE_DATABASE_PASSWORD)@{{ template "stellar-horizon.stellar-core.postgresql.fullname" . }}/stellar-core?sslmode=disable
{{- else }}
- name: STELLAR_CORE_URL
  value: {{ .Values.existingStellarCore.url }}
{{- with .Values.existingStellarCore.databasePasswordSecret }}
- name: STELLAR_CORE_DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .name | quote }}
      key: {{ .key | quote }}
{{- end }}
- name: STELLAR_CORE_DATABASE_URL
  value: {{ .Values.existingStellarCore.databaseUrl }}
{{- end }}
{{- with .Values.networkPassphrase }}
- name: NETWORK_PASSPHRASE
  value: {{ . | quote }}
{{- end }}
{{- end -}}
