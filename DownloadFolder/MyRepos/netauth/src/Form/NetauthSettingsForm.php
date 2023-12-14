<?php

namespace Drupal\netauth\Form;

use Drupal\Core\Form\ConfigFormBase;
use Drupal\Core\Form\FormStateInterface;
use Drupal\Core\StringTranslation\TranslatableMarkup;

/**
 * Netauth settings form.
 */
class NetauthSettingsForm extends ConfigFormBase {

  /**
   * {@inheritdoc}
   */
  public function getFormId() {
    return 'netauth_settings_form';
  }

  /**
   * Implements hook_form().
   *
   * The callback function for settings up the form for netFORUM sso auth.
   */
  public function buildForm(array $form, FormStateInterface $form_state) {
    $config = $this->config('netauth.settings');
    $form = parent::buildForm($form, $form_state);

    $xweb_enable = $config->get('netauth_enabled');
    $xweb_url = $config->get('netauth_wsdl_url');
    $xweb_user = $config->get('netauth_user');
    $xweb_pass = $config->get('netauth_pass');
    $config->set('secret', 'HpxH7AXoznKkpNES8B9s');
    $config->set('ttl', '6400');
    $config->set('timeout', '10');
    $config->set('conn_timeout', '9');

    $form['overview'] = [
      '#markup' => new TranslatableMarkup('Manage netFORUM SSO Module Settings.'),
      '#prefix' => '<p>',
      '#suffix' => '</p>',
    ];
    $form['netauth_enabled'] = [
      '#title' => new TranslatableMarkup('Enable netFORUM Authentication'),
      '#description' => new TranslatableMarkup('When enabled, allows users to sign in using Avectra netFORUM credentials.'),
      '#type' => 'checkbox',
      '#default_value' => $xweb_enable['netauth_enabled'],
      '#prefix' => '<div class="form-group">',
      '#suffix' => '</div>',
    ];
    $form['xweb'] = [
      '#type' => 'details',
      '#title' => new TranslatableMarkup('netFORUM Configuration'),
      '#open' => TRUE,
    ];
    $form['xweb']['netauth_wsdl_url'] = [
      '#title' => new TranslatableMarkup('xWeb WSDL Url'),
      '#description' => new TranslatableMarkup('xWeb WSDL url, must start with http:// or https://'),
      '#type' => 'textfield',
      '#required' => TRUE,
      '#default_value' => $xweb_url['netauth_wsdl_url'],
      '#prefix' => '<div class="form-group">',
      '#suffix' => '</div>',
    ];
    $form['xweb']['netauth_user'] = [
      '#title' => new TranslatableMarkup('xWeb Username'),
      '#description' => new TranslatableMarkup('Username to the xWeb user account, minimum 5 characters format (a-z 0-9 _-)'),
      '#type' => 'textfield',
      '#required' => TRUE,
      '#default_value' => $xweb_user['netauth_user'],
      '#prefix' => '<div class="form-group">',
      '#suffix' => '</div>',
    ];
    $form['xweb']['netauth_pass'] = [
      '#title' => new TranslatableMarkup('xWeb Password'),
      '#description' => new TranslatableMarkup('Password to the xWeb user account, minimum 5 characters.'),
      '#type' => 'textfield',
      '#required' => TRUE,
      '#default_value' => $xweb_pass['netauth_pass'],
      '#prefix' => '<div class="form-group">',
      '#suffix' => '</div>',
    ];
    $form['cache'] = [
      '#title' => $this->t('netFORUM Cache'),
      '#description' => $this->t('Cache configuration for netFORUM module.'),
      '#type' => 'details',
      '#open' => FALSE,
    ];
    $form['cache']['netauth_secret'] = [
      '#title' => new TranslatableMarkup('Cache Secret Key'),
      '#description' => new TranslatableMarkup('Enter exactly 16 or 20 random characters for cache encryption.'),
      '#type' => 'textfield',
      '#required' => TRUE,
      '#default_value' => $config->get('secret'),
      '#prefix' => '<div class="form-group">',
      '#suffix' => '</div>',
    ];
    $form['cache']['netauth_ttl'] = [
      '#title' => new TranslatableMarkup('Cache TTL'),
      '#description' => new TranslatableMarkup('Enter cache time to live settings in seconds.'),
      '#type' => 'textfield',
      '#required' => TRUE,
      '#default_value' => $config->get('ttl'),
      '#prefix' => '<div class="form-group">',
      '#suffix' => '</div>',
    ];
    $form['availability'] = [
      '#title' => new TranslatableMarkup('netFORUM Availability'),
      '#description' => new TranslatableMarkup('Connection timeout settings for netFORUM.'),
      '#type' => 'details',
      '#open' => FALSE,
    ];
    $form['availability']['netauth_timeout'] = [
      '#type' => 'textfield',
      '#title' => new TranslatableMarkup('Slow query limit'),
      '#description' => new TranslatableMarkup('Any xWeb requests over this time limit are marked with warnings in the system logs.'),
      '#after_field' => new TranslatableMarkup('seconds'),
      '#field_suffix' => new TranslatableMarkup('seconds'),
      '#default_value' => $config->get('timeout'),
      '#prefix' => '<div class="form-group">',
      '#suffix' => '</div>',
    ];
    $form['availability']['netauth_connection_timeout'] = [
      '#type' => 'textfield',
      '#title' => new TranslatableMarkup('xWeb timeout'),
      '#description' => new TranslatableMarkup('If netFORUM cannot be contacted in this time it is logged as an error'),
      '#field_suffix' => new TranslatableMarkup('seconds'),
      '#default_value' => $config->get('conn_timeout'),
      '#prefix' => '<div class="form-group">',
      '#suffix' => '</div>',
    ];
    return $form;
  }

  /**
   * Implements hook_validate().
   */
  public function validateForm(array &$form, FormStateInterface $form_state) {
    $values = $form_state->getValues();

    // Validate enable status.
    if (!$values['netauth_enabled']) {
      $form_state->setErrorByName('netauth_enabled', new TranslatableMarkup('Did you forget to enable External Authentication?'));
    }

    // Validate wsdl url.
    if (!preg_match('/^(?:ftp|https?|feed):\/\/?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?(\?WSDL)$/', $values['netauth_wsdl_url'])) {
      $form_state->setErrorByName('netauth_wsdl_url', new TranslatableMarkup('Invalid WSDL Url, must be a complete url starting with http://... or https://'));
    }

    // Validate xWeb username.
    if (!preg_match('/^[a-z0-9_-]{5,64}$/', $values['netauth_user'])) {
      $form_state->setErrorByName('netauth_user', new TranslatableMarkup('Invalid Username; must be alpha numeric with minimum 5 characters.'));
    }

    // Validate xWeb password.
    if (!preg_match('/^.{5,64}$/', $values['netauth_pass'])) {
      $form_state->setErrorByName('netauth_pass', new TranslatableMarkup('Invalid Password; must be minimum 5 characters.'));
    }

    // Validate cache secret.
    if (!preg_match('/^.{16,20}$/', $values['netauth_secret'])) {
      $form_state->setErrorByName('netauth_secret', new TranslatableMarkup('Netforum Cache Secret key must be 16 or 20 characters.'));
    }

    // Validate cache ttl.
    if (!is_numeric($values['netauth_ttl'])) {
      $form_state->setErrorByName('netauth_ttl', new TranslatableMarkup('NetForum cache ttl must be numeric.'));
    }

    // Validate connection timeouts.
    if (!is_numeric($values['netauth_timeout']) || !is_numeric($values['netauth_connection_timeout'])) {
      $form_state->setErrorByName('netauth_timeout', new TranslatableMarkup('NetForum connection timeouts must be numeric.'));
    }

    // Validate connection timeouts.
    if ($values['netauth_timeout'] <= 5 || $values['netauth_connection_timeout'] <= 5) {
      $form_state->setErrorByName('netauth_timeout', new TranslatableMarkup('NetForum connection timeouts must be greater than 5.'));
    }
    return parent::validateForm($form, $form_state);
  }

  /**
   * {@inheritdoc}
   */
  public function submitForm(array &$form, FormStateInterface $form_state) {
    parent::submitForm($form, $form_state);

    $this->config('netauth.settings')
      ->set('netauth_enabled', $form_state->getValues('netauth_enabled'))
      ->set('netauth_wsdl_url', $form_state->getValues('netauth_wsdl_url'))
      ->set('netauth_user', $form_state->getValues('netauth_user'))
      ->set('netauth_pass', $form_state->getValues('netauth_pass'))
      ->set('netauth_secret', $form_state->getValues('netauth_secret'))
      ->set('netauth_ttl', $form_state->getValues('netauth_ttl'))
      ->set('netauth_timeout', $form_state->getValues('netauth_timeout'))
      ->set('netauth_connection_timeout', $form_state->getValues('netauth_connection_timeout'))
      ->save();
  }

  /**
   * {@inheritdoc}
   */
  protected function getEditableConfigNames() {
    return ['netauth.settings'];
  }

}
