# Generated by Django 5.1.5 on 2025-02-05 01:16

import django.db.models.deletion
import wagtail.fields
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('picata', '0001_initial'),
        ('wagtailcore', '0094_alter_page_locale'),
    ]

    operations = [
        migrations.CreateModel(
            name='PostSeries',
            fields=[
                ('page_ptr', models.OneToOneField(auto_created=True, on_delete=django.db.models.deletion.CASCADE, parent_link=True, primary_key=True, serialize=False, to='wagtailcore.page')),
                ('introduction', wagtail.fields.StreamField([('rich_text', 0), ('image', 1)], blank=True, block_lookup={0: ('wagtail.blocks.RichTextBlock', (), {}), 1: ('picata.blocks.WrappedImageChooserBlock', (), {})})),
            ],
            options={
                'abstract': False,
            },
            bases=('wagtailcore.page',),
        ),
    ]
