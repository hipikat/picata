--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6 (Ubuntu 16.6-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.6 (Ubuntu 16.6-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: wagtail
--

COPY public.auth_group (id, name) FROM stdin;
1	Moderators
2	Editors
\.


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: wagtail
--

COPY public.django_content_type (id, app_label, model) FROM stdin;
1	wagtailcore	page
2	wagtailcore	groupapprovaltask
3	wagtailcore	locale
4	wagtailcore	site
5	wagtailcore	modellogentry
6	wagtailcore	collectionviewrestriction
7	wagtailcore	collection
8	wagtailcore	groupcollectionpermission
9	wagtailcore	uploadedfile
10	wagtailcore	referenceindex
11	wagtailcore	revision
12	wagtailcore	grouppagepermission
13	wagtailcore	pageviewrestriction
14	wagtailcore	workflowpage
15	wagtailcore	workflowcontenttype
16	wagtailcore	workflowtask
17	wagtailcore	task
18	wagtailcore	workflow
19	wagtailcore	workflowstate
20	wagtailcore	taskstate
21	wagtailcore	pagelogentry
22	wagtailcore	comment
23	wagtailcore	commentreply
24	wagtailcore	pagesubscription
25	wagtailadmin	admin
26	wagtaildocs	document
27	wagtailimages	image
28	hpk	article
29	hpk	articletag
30	hpk	articletype
31	hpk	basicpage
32	hpk	postgrouppage
33	hpk	articletagitem
34	wagtailforms	formsubmission
35	wagtailredirects	redirect
36	wagtailembeds	embed
37	wagtailusers	userprofile
38	wagtailimages	rendition
39	wagtailsearch	indexentry
40	wagtailadmin	editingsession
41	taggit	tag
42	taggit	taggeditem
43	admin	logentry
44	auth	permission
45	auth	group
46	auth	user
47	contenttypes	contenttype
48	sessions	session
\.


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: wagtail
--

COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add locale	3	add_locale
2	Can change locale	3	change_locale
3	Can delete locale	3	delete_locale
4	Can view locale	3	view_locale
5	Can add site	4	add_site
6	Can change site	4	change_site
7	Can delete site	4	delete_site
8	Can view site	4	view_site
9	Can add model log entry	5	add_modellogentry
10	Can change model log entry	5	change_modellogentry
11	Can delete model log entry	5	delete_modellogentry
12	Can view model log entry	5	view_modellogentry
13	Can add collection view restriction	6	add_collectionviewrestriction
14	Can change collection view restriction	6	change_collectionviewrestriction
15	Can delete collection view restriction	6	delete_collectionviewrestriction
16	Can view collection view restriction	6	view_collectionviewrestriction
17	Can add collection	7	add_collection
18	Can change collection	7	change_collection
19	Can delete collection	7	delete_collection
20	Can view collection	7	view_collection
21	Can add group collection permission	8	add_groupcollectionpermission
22	Can change group collection permission	8	change_groupcollectionpermission
23	Can delete group collection permission	8	delete_groupcollectionpermission
24	Can view group collection permission	8	view_groupcollectionpermission
25	Can add uploaded file	9	add_uploadedfile
26	Can change uploaded file	9	change_uploadedfile
27	Can delete uploaded file	9	delete_uploadedfile
28	Can view uploaded file	9	view_uploadedfile
29	Can add reference index	10	add_referenceindex
30	Can change reference index	10	change_referenceindex
31	Can delete reference index	10	delete_referenceindex
32	Can view reference index	10	view_referenceindex
33	Can add page	1	add_page
34	Can change page	1	change_page
35	Can delete page	1	delete_page
36	Can view page	1	view_page
37	Delete pages with children	1	bulk_delete_page
38	Lock/unlock pages you've locked	1	lock_page
39	Publish any page	1	publish_page
40	Unlock any page	1	unlock_page
41	Can add revision	11	add_revision
42	Can change revision	11	change_revision
43	Can delete revision	11	delete_revision
44	Can view revision	11	view_revision
45	Can add group page permission	12	add_grouppagepermission
46	Can change group page permission	12	change_grouppagepermission
47	Can delete group page permission	12	delete_grouppagepermission
48	Can view group page permission	12	view_grouppagepermission
49	Can add page view restriction	13	add_pageviewrestriction
50	Can change page view restriction	13	change_pageviewrestriction
51	Can delete page view restriction	13	delete_pageviewrestriction
52	Can view page view restriction	13	view_pageviewrestriction
53	Can add workflow page	14	add_workflowpage
54	Can change workflow page	14	change_workflowpage
55	Can delete workflow page	14	delete_workflowpage
56	Can view workflow page	14	view_workflowpage
57	Can add workflow content type	15	add_workflowcontenttype
58	Can change workflow content type	15	change_workflowcontenttype
59	Can delete workflow content type	15	delete_workflowcontenttype
60	Can view workflow content type	15	view_workflowcontenttype
61	Can add workflow task order	16	add_workflowtask
62	Can change workflow task order	16	change_workflowtask
63	Can delete workflow task order	16	delete_workflowtask
64	Can view workflow task order	16	view_workflowtask
65	Can add task	17	add_task
66	Can change task	17	change_task
67	Can delete task	17	delete_task
68	Can view task	17	view_task
69	Can add workflow	18	add_workflow
70	Can change workflow	18	change_workflow
71	Can delete workflow	18	delete_workflow
72	Can view workflow	18	view_workflow
73	Can add Group approval task	2	add_groupapprovaltask
74	Can change Group approval task	2	change_groupapprovaltask
75	Can delete Group approval task	2	delete_groupapprovaltask
76	Can view Group approval task	2	view_groupapprovaltask
77	Can add Workflow state	19	add_workflowstate
78	Can change Workflow state	19	change_workflowstate
79	Can delete Workflow state	19	delete_workflowstate
80	Can view Workflow state	19	view_workflowstate
81	Can add Task state	20	add_taskstate
82	Can change Task state	20	change_taskstate
83	Can delete Task state	20	delete_taskstate
84	Can view Task state	20	view_taskstate
85	Can add page log entry	21	add_pagelogentry
86	Can change page log entry	21	change_pagelogentry
87	Can delete page log entry	21	delete_pagelogentry
88	Can view page log entry	21	view_pagelogentry
89	Can add comment	22	add_comment
90	Can change comment	22	change_comment
91	Can delete comment	22	delete_comment
92	Can view comment	22	view_comment
93	Can add comment reply	23	add_commentreply
94	Can change comment reply	23	change_commentreply
95	Can delete comment reply	23	delete_commentreply
96	Can view comment reply	23	view_commentreply
97	Can add page subscription	24	add_pagesubscription
98	Can change page subscription	24	change_pagesubscription
99	Can delete page subscription	24	delete_pagesubscription
100	Can view page subscription	24	view_pagesubscription
101	Can access Wagtail admin	25	access_admin
102	Can add document	26	add_document
103	Can change document	26	change_document
104	Can delete document	26	delete_document
105	Can choose document	26	choose_document
106	Can add image	27	add_image
107	Can change image	27	change_image
108	Can delete image	27	delete_image
109	Can choose image	27	choose_image
110	Can add Article	28	add_article
111	Can change Article	28	change_article
112	Can delete Article	28	delete_article
113	Can view Article	28	view_article
114	Can add Article Tag	29	add_articletag
115	Can change Article Tag	29	change_articletag
116	Can delete Article Tag	29	delete_articletag
117	Can view Article Tag	29	view_articletag
118	Can add article type	30	add_articletype
119	Can change article type	30	change_articletype
120	Can delete article type	30	delete_articletype
121	Can view article type	30	view_articletype
122	Can add Basic Page	31	add_basicpage
123	Can change Basic Page	31	change_basicpage
124	Can delete Basic Page	31	delete_basicpage
125	Can view Basic Page	31	view_basicpage
126	Can add Post Group	32	add_postgrouppage
127	Can change Post Group	32	change_postgrouppage
128	Can delete Post Group	32	delete_postgrouppage
129	Can view Post Group	32	view_postgrouppage
130	Can add article tag item	33	add_articletagitem
131	Can change article tag item	33	change_articletagitem
132	Can delete article tag item	33	delete_articletagitem
133	Can view article tag item	33	view_articletagitem
134	Can add form submission	34	add_formsubmission
135	Can change form submission	34	change_formsubmission
136	Can delete form submission	34	delete_formsubmission
137	Can view form submission	34	view_formsubmission
138	Can add redirect	35	add_redirect
139	Can change redirect	35	change_redirect
140	Can delete redirect	35	delete_redirect
141	Can view redirect	35	view_redirect
142	Can add embed	36	add_embed
143	Can change embed	36	change_embed
144	Can delete embed	36	delete_embed
145	Can view embed	36	view_embed
146	Can add user profile	37	add_userprofile
147	Can change user profile	37	change_userprofile
148	Can delete user profile	37	delete_userprofile
149	Can view user profile	37	view_userprofile
150	Can view document	26	view_document
151	Can view image	27	view_image
152	Can add rendition	38	add_rendition
153	Can change rendition	38	change_rendition
154	Can delete rendition	38	delete_rendition
155	Can view rendition	38	view_rendition
156	Can add index entry	39	add_indexentry
157	Can change index entry	39	change_indexentry
158	Can delete index entry	39	delete_indexentry
159	Can view index entry	39	view_indexentry
160	Can add editing session	40	add_editingsession
161	Can change editing session	40	change_editingsession
162	Can delete editing session	40	delete_editingsession
163	Can view editing session	40	view_editingsession
164	Can add tag	41	add_tag
165	Can change tag	41	change_tag
166	Can delete tag	41	delete_tag
167	Can view tag	41	view_tag
168	Can add tagged item	42	add_taggeditem
169	Can change tagged item	42	change_taggeditem
170	Can delete tagged item	42	delete_taggeditem
171	Can view tagged item	42	view_taggeditem
172	Can add log entry	43	add_logentry
173	Can change log entry	43	change_logentry
174	Can delete log entry	43	delete_logentry
175	Can view log entry	43	view_logentry
176	Can add permission	44	add_permission
177	Can change permission	44	change_permission
178	Can delete permission	44	delete_permission
179	Can view permission	44	view_permission
180	Can add group	45	add_group
181	Can change group	45	change_group
182	Can delete group	45	delete_group
183	Can view group	45	view_group
184	Can add user	46	add_user
185	Can change user	46	change_user
186	Can delete user	46	delete_user
187	Can view user	46	view_user
188	Can add content type	47	add_contenttype
189	Can change content type	47	change_contenttype
190	Can delete content type	47	delete_contenttype
191	Can view content type	47	view_contenttype
192	Can add session	48	add_session
193	Can change session	48	change_session
194	Can delete session	48	delete_session
195	Can view session	48	view_session
\.


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: wagtail
--

COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
1	1	101
2	2	101
3	1	104
4	1	102
5	1	103
6	2	104
7	2	102
8	2	103
9	1	105
10	2	105
11	1	106
12	1	107
13	1	108
14	2	106
15	2	107
16	2	108
17	1	109
18	2	109
\.


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: wagtail
--

COPY public.django_migrations (id, app, name, applied) FROM stdin;
1	contenttypes	0001_initial	2024-12-19 02:29:21.341482+00
2	auth	0001_initial	2024-12-19 02:29:21.441521+00
3	admin	0001_initial	2024-12-19 02:29:21.472897+00
4	admin	0002_logentry_remove_auto_add	2024-12-19 02:29:21.483597+00
5	admin	0003_logentry_add_action_flag_choices	2024-12-19 02:29:21.495408+00
6	contenttypes	0002_remove_content_type_name	2024-12-19 02:29:21.517642+00
7	auth	0002_alter_permission_name_max_length	2024-12-19 02:29:21.527547+00
8	auth	0003_alter_user_email_max_length	2024-12-19 02:29:21.535562+00
9	auth	0004_alter_user_username_opts	2024-12-19 02:29:21.543424+00
10	auth	0005_alter_user_last_login_null	2024-12-19 02:29:21.556407+00
11	auth	0006_require_contenttypes_0002	2024-12-19 02:29:21.558657+00
12	auth	0007_alter_validators_add_error_messages	2024-12-19 02:29:21.57202+00
13	auth	0008_alter_user_username_max_length	2024-12-19 02:29:21.586701+00
14	auth	0009_alter_user_last_name_max_length	2024-12-19 02:29:21.599494+00
15	auth	0010_alter_group_name_max_length	2024-12-19 02:29:21.610848+00
16	auth	0011_update_proxy_permissions	2024-12-19 02:29:21.621217+00
17	auth	0012_alter_user_first_name_max_length	2024-12-19 02:29:21.631982+00
18	wagtailcore	0001_initial	2024-12-19 02:29:21.847107+00
19	wagtailcore	0002_initial_data	2024-12-19 02:29:21.848433+00
20	wagtailcore	0003_add_uniqueness_constraint_on_group_page_permission	2024-12-19 02:29:21.849342+00
21	wagtailcore	0004_page_locked	2024-12-19 02:29:21.850159+00
22	wagtailcore	0005_add_page_lock_permission_to_moderators	2024-12-19 02:29:21.851001+00
23	wagtailcore	0006_add_lock_page_permission	2024-12-19 02:29:21.851775+00
24	wagtailcore	0007_page_latest_revision_created_at	2024-12-19 02:29:21.852624+00
25	wagtailcore	0008_populate_latest_revision_created_at	2024-12-19 02:29:21.853482+00
26	wagtailcore	0009_remove_auto_now_add_from_pagerevision_created_at	2024-12-19 02:29:21.854221+00
27	wagtailcore	0010_change_page_owner_to_null_on_delete	2024-12-19 02:29:21.85505+00
28	wagtailcore	0011_page_first_published_at	2024-12-19 02:29:21.855806+00
29	wagtailcore	0012_extend_page_slug_field	2024-12-19 02:29:21.856761+00
30	wagtailcore	0013_update_golive_expire_help_text	2024-12-19 02:29:21.857655+00
31	wagtailcore	0014_add_verbose_name	2024-12-19 02:29:21.858543+00
32	wagtailcore	0015_add_more_verbose_names	2024-12-19 02:29:21.859694+00
33	wagtailcore	0016_change_page_url_path_to_text_field	2024-12-19 02:29:21.860618+00
34	wagtailcore	0017_change_edit_page_permission_description	2024-12-19 02:29:21.874376+00
35	wagtailcore	0018_pagerevision_submitted_for_moderation_index	2024-12-19 02:29:21.890301+00
36	wagtailcore	0019_verbose_names_cleanup	2024-12-19 02:29:21.941102+00
37	wagtailcore	0020_add_index_on_page_first_published_at	2024-12-19 02:29:21.960087+00
38	wagtailcore	0021_capitalizeverbose	2024-12-19 02:29:22.460746+00
39	wagtailcore	0022_add_site_name	2024-12-19 02:29:22.478591+00
40	wagtailcore	0023_alter_page_revision_on_delete_behaviour	2024-12-19 02:29:22.49886+00
41	wagtailcore	0024_collection	2024-12-19 02:29:22.515713+00
42	wagtailcore	0025_collection_initial_data	2024-12-19 02:29:22.532379+00
43	wagtailcore	0026_group_collection_permission	2024-12-19 02:29:22.583481+00
44	wagtailcore	0027_fix_collection_path_collation	2024-12-19 02:29:22.602653+00
45	wagtailcore	0024_alter_page_content_type_on_delete_behaviour	2024-12-19 02:29:22.620664+00
46	wagtailcore	0028_merge	2024-12-19 02:29:22.623119+00
47	wagtailcore	0029_unicode_slugfield_dj19	2024-12-19 02:29:22.640342+00
48	wagtailcore	0030_index_on_pagerevision_created_at	2024-12-19 02:29:22.659925+00
49	wagtailcore	0031_add_page_view_restriction_types	2024-12-19 02:29:22.729589+00
50	wagtailcore	0032_add_bulk_delete_page_permission	2024-12-19 02:29:22.748846+00
51	wagtailcore	0033_remove_golive_expiry_help_text	2024-12-19 02:29:22.777673+00
52	wagtailcore	0034_page_live_revision	2024-12-19 02:29:22.807802+00
53	wagtailcore	0035_page_last_published_at	2024-12-19 02:29:22.8308+00
54	wagtailcore	0036_populate_page_last_published_at	2024-12-19 02:29:22.852446+00
55	wagtailcore	0037_set_page_owner_editable	2024-12-19 02:29:22.87238+00
56	wagtailcore	0038_make_first_published_at_editable	2024-12-19 02:29:22.888765+00
57	wagtailcore	0039_collectionviewrestriction	2024-12-19 02:29:22.956586+00
58	wagtailcore	0040_page_draft_title	2024-12-19 02:29:22.992011+00
59	wagtailcore	0041_group_collection_permissions_verbose_name_plural	2024-12-19 02:29:23.008027+00
60	wagtailcore	0042_index_on_pagerevision_approved_go_live_at	2024-12-19 02:29:23.032226+00
61	wagtailcore	0043_lock_fields	2024-12-19 02:29:23.08315+00
62	wagtailcore	0044_add_unlock_grouppagepermission	2024-12-19 02:29:23.099126+00
63	wagtailcore	0045_assign_unlock_grouppagepermission	2024-12-19 02:29:23.126257+00
64	wagtailcore	0046_site_name_remove_null	2024-12-19 02:29:23.146317+00
65	wagtailcore	0047_add_workflow_models	2024-12-19 02:29:23.581482+00
66	wagtailcore	0048_add_default_workflows	2024-12-19 02:29:23.648243+00
67	wagtailcore	0049_taskstate_finished_by	2024-12-19 02:29:23.685543+00
68	wagtailcore	0050_workflow_rejected_to_needs_changes	2024-12-19 02:29:23.741345+00
69	wagtailcore	0051_taskstate_comment	2024-12-19 02:29:23.773316+00
70	wagtailcore	0052_pagelogentry	2024-12-19 02:29:23.828406+00
71	wagtailcore	0053_locale_model	2024-12-19 02:29:23.846988+00
72	wagtailcore	0054_initial_locale	2024-12-19 02:29:23.872661+00
73	wagtailcore	0055_page_locale_fields	2024-12-19 02:29:23.957633+00
74	wagtailcore	0056_page_locale_fields_populate	2024-12-19 02:29:23.99007+00
75	wagtailcore	0057_page_locale_fields_notnull	2024-12-19 02:29:24.042557+00
76	wagtailcore	0058_page_alias_of	2024-12-19 02:29:24.075478+00
77	wagtailcore	0059_apply_collection_ordering	2024-12-19 02:29:24.102785+00
78	wagtailcore	0060_fix_workflow_unique_constraint	2024-12-19 02:29:24.141329+00
79	wagtailcore	0061_change_promote_tab_helpt_text_and_verbose_names	2024-12-19 02:29:24.17674+00
80	wagtailcore	0062_comment_models_and_pagesubscription	2024-12-19 02:29:24.327691+00
81	wagtailcore	0063_modellogentry	2024-12-19 02:29:24.561219+00
82	wagtailcore	0064_log_timestamp_indexes	2024-12-19 02:29:24.612457+00
83	wagtailcore	0065_log_entry_uuid	2024-12-19 02:29:24.658432+00
84	wagtailcore	0066_collection_management_permissions	2024-12-19 02:29:24.690933+00
85	wagtailcore	0067_alter_pagerevision_content_json	2024-12-19 02:29:24.766315+00
86	wagtailcore	0068_log_entry_empty_object	2024-12-19 02:29:24.809684+00
87	wagtailcore	0069_log_entry_jsonfield	2024-12-19 02:29:24.936746+00
88	wagtailcore	0070_rename_pagerevision_revision	2024-12-19 02:29:25.259101+00
89	wagtailcore	0071_populate_revision_content_type	2024-12-19 02:29:25.297585+00
90	wagtailcore	0072_alter_revision_content_type_notnull	2024-12-19 02:29:25.376458+00
91	wagtailcore	0073_page_latest_revision	2024-12-19 02:29:25.412279+00
92	wagtailcore	0074_revision_object_str	2024-12-19 02:29:25.620306+00
93	wagtailcore	0075_populate_latest_revision_and_revision_object_str	2024-12-19 02:29:25.678622+00
94	wagtailcore	0076_modellogentry_revision	2024-12-19 02:29:25.710749+00
95	wagtailcore	0077_alter_revision_user	2024-12-19 02:29:25.736656+00
96	wagtailcore	0078_referenceindex	2024-12-19 02:29:25.78531+00
97	wagtailcore	0079_rename_taskstate_page_revision	2024-12-19 02:29:25.815658+00
98	wagtailcore	0080_generic_workflowstate	2024-12-19 02:29:26.037869+00
99	wagtailcore	0081_populate_workflowstate_content_type	2024-12-19 02:29:26.073501+00
100	wagtailcore	0082_alter_workflowstate_content_type_notnull	2024-12-19 02:29:26.144022+00
101	wagtailcore	0083_workflowcontenttype	2024-12-19 02:29:26.19463+00
102	wagtailcore	0084_add_default_page_permissions	2024-12-19 02:29:26.22323+00
103	wagtailcore	0085_add_grouppagepermission_permission	2024-12-19 02:29:26.280924+00
104	wagtailcore	0086_populate_grouppagepermission_permission	2024-12-19 02:29:26.360126+00
105	wagtailcore	0087_alter_grouppagepermission_unique_together_and_more	2024-12-19 02:29:26.585312+00
106	wagtailcore	0088_fix_log_entry_json_timestamps	2024-12-19 02:29:26.667271+00
107	wagtailcore	0089_log_entry_data_json_null_to_object	2024-12-19 02:29:26.69933+00
108	wagtailcore	0090_remove_grouppagepermission_permission_type	2024-12-19 02:29:26.812333+00
109	wagtailcore	0091_remove_revision_submitted_for_moderation	2024-12-19 02:29:26.838345+00
110	wagtailcore	0092_alter_collectionviewrestriction_password_and_more	2024-12-19 02:29:26.906041+00
111	wagtailcore	0093_uploadedfile	2024-12-19 02:29:26.959449+00
112	wagtailcore	0094_alter_page_locale	2024-12-19 02:29:27.00409+00
113	taggit	0001_initial	2024-12-19 02:29:27.078716+00
114	taggit	0002_auto_20150616_2121	2024-12-19 02:29:27.100595+00
115	taggit	0003_taggeditem_add_unique_index	2024-12-19 02:29:27.124237+00
116	taggit	0004_alter_taggeditem_content_type_alter_taggeditem_tag	2024-12-19 02:29:27.186207+00
117	taggit	0005_auto_20220424_2025	2024-12-19 02:29:27.193318+00
118	taggit	0006_rename_taggeditem_content_type_object_id_taggit_tagg_content_8fc721_idx	2024-12-19 02:29:27.228747+00
119	hpk	0001_initial	2024-12-19 02:29:27.650072+00
120	sessions	0001_initial	2024-12-19 02:29:27.665313+00
121	wagtailadmin	0001_create_admin_access_permissions	2024-12-19 02:29:27.71843+00
122	wagtailadmin	0002_admin	2024-12-19 02:29:27.723501+00
123	wagtailadmin	0003_admin_managed	2024-12-19 02:29:27.731878+00
124	wagtailadmin	0004_editingsession	2024-12-19 02:29:27.789899+00
125	wagtailadmin	0005_editingsession_is_editing	2024-12-19 02:29:27.81996+00
126	wagtaildocs	0001_initial	2024-12-19 02:29:27.871841+00
127	wagtaildocs	0002_initial_data	2024-12-19 02:29:27.926846+00
128	wagtaildocs	0003_add_verbose_names	2024-12-19 02:29:28.008219+00
129	wagtaildocs	0004_capitalizeverbose	2024-12-19 02:29:28.208102+00
130	wagtaildocs	0005_document_collection	2024-12-19 02:29:28.279525+00
131	wagtaildocs	0006_copy_document_permissions_to_collections	2024-12-19 02:29:28.486469+00
132	wagtaildocs	0005_alter_uploaded_by_user_on_delete_action	2024-12-19 02:29:28.527863+00
133	wagtaildocs	0007_merge	2024-12-19 02:29:28.531586+00
134	wagtaildocs	0008_document_file_size	2024-12-19 02:29:28.560591+00
135	wagtaildocs	0009_document_verbose_name_plural	2024-12-19 02:29:28.589712+00
136	wagtaildocs	0010_document_file_hash	2024-12-19 02:29:28.622765+00
137	wagtaildocs	0011_add_choose_permissions	2024-12-19 02:29:28.728969+00
138	wagtaildocs	0012_uploadeddocument	2024-12-19 02:29:28.782943+00
139	wagtaildocs	0013_delete_uploadeddocument	2024-12-19 02:29:28.788546+00
140	wagtaildocs	0014_alter_document_file_size	2024-12-19 02:29:28.82761+00
141	wagtailembeds	0001_initial	2024-12-19 02:29:28.848783+00
142	wagtailembeds	0002_add_verbose_names	2024-12-19 02:29:28.855365+00
143	wagtailembeds	0003_capitalizeverbose	2024-12-19 02:29:28.860512+00
144	wagtailembeds	0004_embed_verbose_name_plural	2024-12-19 02:29:28.866076+00
145	wagtailembeds	0005_specify_thumbnail_url_max_length	2024-12-19 02:29:28.872783+00
146	wagtailembeds	0006_add_embed_hash	2024-12-19 02:29:28.880388+00
147	wagtailembeds	0007_populate_hash	2024-12-19 02:29:28.925178+00
148	wagtailembeds	0008_allow_long_urls	2024-12-19 02:29:28.960528+00
149	wagtailembeds	0009_embed_cache_until	2024-12-19 02:29:28.972964+00
150	wagtailforms	0001_initial	2024-12-19 02:29:29.023332+00
151	wagtailforms	0002_add_verbose_names	2024-12-19 02:29:29.062888+00
152	wagtailforms	0003_capitalizeverbose	2024-12-19 02:29:29.100207+00
153	wagtailforms	0004_add_verbose_name_plural	2024-12-19 02:29:29.124659+00
154	wagtailforms	0005_alter_formsubmission_form_data	2024-12-19 02:29:29.153992+00
155	wagtailimages	0001_initial	2024-12-19 02:29:29.602917+00
156	wagtailimages	0002_initial_data	2024-12-19 02:29:29.604168+00
157	wagtailimages	0003_fix_focal_point_fields	2024-12-19 02:29:29.605175+00
158	wagtailimages	0004_make_focal_point_key_not_nullable	2024-12-19 02:29:29.606189+00
159	wagtailimages	0005_make_filter_spec_unique	2024-12-19 02:29:29.607171+00
160	wagtailimages	0006_add_verbose_names	2024-12-19 02:29:29.608169+00
161	wagtailimages	0007_image_file_size	2024-12-19 02:29:29.609194+00
162	wagtailimages	0008_image_created_at_index	2024-12-19 02:29:29.610263+00
163	wagtailimages	0009_capitalizeverbose	2024-12-19 02:29:29.611309+00
164	wagtailimages	0010_change_on_delete_behaviour	2024-12-19 02:29:29.612228+00
165	wagtailimages	0011_image_collection	2024-12-19 02:29:29.617573+00
166	wagtailimages	0012_copy_image_permissions_to_collections	2024-12-19 02:29:29.618859+00
167	wagtailimages	0013_make_rendition_upload_callable	2024-12-19 02:29:29.619736+00
168	wagtailimages	0014_add_filter_spec_field	2024-12-19 02:29:29.620535+00
169	wagtailimages	0015_fill_filter_spec_field	2024-12-19 02:29:29.621461+00
170	wagtailimages	0016_deprecate_rendition_filter_relation	2024-12-19 02:29:29.622208+00
171	wagtailimages	0017_reduce_focal_point_key_max_length	2024-12-19 02:29:29.623063+00
172	wagtailimages	0018_remove_rendition_filter	2024-12-19 02:29:29.624134+00
173	wagtailimages	0019_delete_filter	2024-12-19 02:29:29.62518+00
174	wagtailimages	0020_add-verbose-name	2024-12-19 02:29:29.626032+00
175	wagtailimages	0021_image_file_hash	2024-12-19 02:29:29.626913+00
176	wagtailimages	0022_uploadedimage	2024-12-19 02:29:29.693944+00
177	wagtailimages	0023_add_choose_permissions	2024-12-19 02:29:29.816252+00
178	wagtailimages	0024_index_image_file_hash	2024-12-19 02:29:29.852543+00
179	wagtailimages	0025_alter_image_file_alter_rendition_file	2024-12-19 02:29:29.898121+00
180	wagtailimages	0026_delete_uploadedimage	2024-12-19 02:29:29.903375+00
181	wagtailimages	0027_image_description	2024-12-19 02:29:29.936116+00
182	wagtailredirects	0001_initial	2024-12-19 02:29:30.008914+00
183	wagtailredirects	0002_add_verbose_names	2024-12-19 02:29:30.097226+00
184	wagtailredirects	0003_make_site_field_editable	2024-12-19 02:29:30.16065+00
185	wagtailredirects	0004_set_unique_on_path_and_site	2024-12-19 02:29:30.214259+00
186	wagtailredirects	0005_capitalizeverbose	2024-12-19 02:29:30.376985+00
187	wagtailredirects	0006_redirect_increase_max_length	2024-12-19 02:29:30.401478+00
188	wagtailredirects	0007_add_autocreate_fields	2024-12-19 02:29:30.637649+00
189	wagtailredirects	0008_add_verbose_name_plural	2024-12-19 02:29:30.660048+00
190	wagtailsearch	0001_initial	2024-12-19 02:29:30.79354+00
191	wagtailsearch	0002_add_verbose_names	2024-12-19 02:29:30.867589+00
192	wagtailsearch	0003_remove_editors_pick	2024-12-19 02:29:30.870572+00
193	wagtailsearch	0004_querydailyhits_verbose_name_plural	2024-12-19 02:29:30.878645+00
194	wagtailsearch	0005_create_indexentry	2024-12-19 02:29:30.966408+00
195	wagtailsearch	0006_customise_indexentry	2024-12-19 02:29:31.09524+00
196	wagtailsearch	0007_delete_editorspick	2024-12-19 02:29:31.103371+00
197	wagtailsearch	0008_remove_query_and_querydailyhits_models	2024-12-19 02:29:31.130891+00
198	wagtailusers	0001_initial	2024-12-19 02:29:31.193981+00
199	wagtailusers	0002_add_verbose_name_on_userprofile	2024-12-19 02:29:31.292005+00
200	wagtailusers	0003_add_verbose_names	2024-12-19 02:29:31.32595+00
201	wagtailusers	0004_capitalizeverbose	2024-12-19 02:29:31.41602+00
202	wagtailusers	0005_make_related_name_wagtail_specific	2024-12-19 02:29:31.608522+00
203	wagtailusers	0006_userprofile_prefered_language	2024-12-19 02:29:31.637796+00
204	wagtailusers	0007_userprofile_current_time_zone	2024-12-19 02:29:31.668259+00
205	wagtailusers	0008_userprofile_avatar	2024-12-19 02:29:31.698983+00
206	wagtailusers	0009_userprofile_verbose_name_plural	2024-12-19 02:29:31.725419+00
207	wagtailusers	0010_userprofile_updated_comments_notifications	2024-12-19 02:29:31.760672+00
208	wagtailusers	0011_userprofile_dismissibles	2024-12-19 02:29:31.802653+00
209	wagtailusers	0012_userprofile_theme	2024-12-19 02:29:31.836134+00
210	wagtailusers	0013_userprofile_density	2024-12-19 02:29:31.873504+00
211	wagtailusers	0014_userprofile_contrast	2024-12-19 02:29:31.903162+00
212	wagtailimages	0001_squashed_0021	2024-12-19 02:29:31.913851+00
213	wagtailcore	0001_squashed_0016_change_page_url_path_to_text_field	2024-12-19 02:29:31.915997+00
214	hpk	0002_alter_article_content_alter_basicpage_content	2024-12-19 22:18:15.379283+00
215	hpk	0003_alter_article_content_alter_basicpage_content	2024-12-19 22:21:39.056011+00
216	hpk	0004_alter_article_content_alter_basicpage_content	2024-12-19 22:24:04.275474+00
\.


--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wagtail
--

SELECT pg_catalog.setval('public.auth_group_id_seq', 2, true);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wagtail
--

SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 18, true);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wagtail
--

SELECT pg_catalog.setval('public.auth_permission_id_seq', 195, true);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wagtail
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 48, true);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wagtail
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 216, true);


--
-- PostgreSQL database dump complete
--

