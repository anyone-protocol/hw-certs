import axios from 'axios'
import https from 'https'
import fs from 'fs'

export async function setupVaultAxios() {
  const axiosVault = axios.create({
    baseURL: process.env.VAULT_ADDR,
    httpsAgent: new https.Agent({
      ca: fs.readFileSync('/etc/ssl/certs/vault-ca.crt')
    }),
    headers: {
      'X-Vault-Token': process.env.VAULT_TOKEN
    }
  })

  // const response = await axiosVault.post('/v1/auth/token/renew-self', {
  //   increment: '2h'
  // })

  // console.log('renew-self response.status', response.status)
  // console.log('renew-self response.statusText', response.statusText)
  // console.log('renew-self response.data', response.data)

  // if (response.data && response.data.auth && response.data.auth.client_token) {
  //   const { auth: { client_token } } = response.data
  //   axiosVault.defaults.headers['X-Vault-Token'] = client_token
  // }

  return axiosVault
}

export async function updateIssuerNames() {
  const axiosVault = await setupVaultAxios()

  const response = await axiosVault.request({
    method: 'LIST',
    url: '/v1/pki/issuers'
  })
  console.log('response.status', response.status)
  console.log('response.statusText', response.statusText)
  console.log('response.data', response.data)
}

updateIssuerNames().catch((err) => { console.error(err); process.exit(1) })
