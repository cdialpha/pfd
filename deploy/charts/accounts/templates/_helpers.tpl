{{/* Chart name, overridable */}}
{{- define "account-svc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Fully qualified app name */}}
{{- define "account-svc.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "account-svc.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Common labels */}}
{{- define "account-svc.labels" -}}
app.kubernetes.io/name: {{ include "account-svc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}

{{/* Selector labels (immutable subset) */}}
{{- define "account-svc.selectorLabels" -}}
app.kubernetes.io/name: {{ include "account-svc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* SA name */}}
{{- define "account-svc.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "account-svc.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}