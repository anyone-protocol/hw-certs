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

  return axiosVault
}

export async function updateIssuerNames() {
  const axiosVault = await setupVaultAxios()

  const response = await axiosVault.request({
    method: 'LIST',
    url: '/v1/pki_hardware/issuers'
  })
  
  if (response.data && response.data.data) {
    const { key_info } = response.data.data

    const issuers = Object
      .keys(key_info)
      .map(issuer_ref => ({ issuer_ref, ...key_info[issuer_ref] }))
    const issuersToUpdate = issuers.filter(issuer => !issuer.issuer_name)
    const issuersWithNames = issuers.filter(issuer => issuer.issuer_name)

    console.log(`Found ${issuers.length} issuers`)
    console.log(
      `Found ${issuersToUpdate.length} issuers without names needing update`
    )
    console.log(`Found ${issuersWithNames.length} issuers with names`)
    console.log('issuersWithNames', issuersWithNames)

    for (const { issuer_ref, serial_number } of issuersToUpdate) {
      await axiosVault.patch(`/v1/pki_hardware/issuer/${issuer_ref}`, {
        issuer_name: (serial_number as string).replace(/:/g, '-')
      })
      console.log(`Updated issuer ${issuer_ref} with name ${serial_number}`)
    }
  }
}

updateIssuerNames().catch((err) => { console.error(err); process.exit(1) })
