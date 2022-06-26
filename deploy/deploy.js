const hre = require('hardhat')

async function main() {
	let deployer, addr1, addr2, addr3, addrs
	;[deployer, addr1, addr2, addr3, ...addrs] = await ethers.getSigners()

	console.log(deployer.address, addr1.address)

	const Contract = await hre.ethers.getContractFactory('WorldIDVerification')
	const contract = await Contract.deploy(
		addr1.address,
		[addr2.address, addr3.address],
		addr3.address,
		'https://google.com'
	)

	const tx = contract.deployTransaction
	console.log('Deployment tx:', tx.hash)

	await contract.deployed()

	console.log('WorldIDVerification deployed to:', contract.address)
	console.log('Deployed by:', deployer.address)
}

main().catch((error) => {
	console.error(error)
	process.exitCode = 1
})
