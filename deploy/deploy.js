const hre = require('hardhat')

async function main() {
	let deployer, addr1, addr2, addr3, addrs
	;[deployer, addr1, addr2, addr3, ...addrs] = await ethers.getSigners()

	const Contract = await hre.ethers.getContractFactory('PoHVerification')
	const contract = await Contract.deploy(
		'0x4023395C3Bb30cb6288d4eD722369C2A510d377A',
		[
			process.env.VERIFIER_ONE_ADDRESS,
			process.env.VERIFIER_TWO_ADDRESS,
			process.env.VERIFIER_THREE_ADDRESS
		],
		process.env.VERIFIER_ONE_ADDRESS,
		'https://example.org'
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
