const { ethers } = require('hardhat')
const { expect } = require('chai')

describe('TourbillonToken', () => {
  const fromGears = (gears) => ethers.utils.formatUnits(gears, '8')
  const toGears = (fullTourb) => ethers.utils.parseUnits(fullTourb, '8')

  it('basic test', async () => {
    const [user] = await ethers.getSigners()
    const TourbillonToken = await ethers.getContractFactory('TestTourbillon')
    const token = await TourbillonToken.deploy()

    expect(await token.balanceOf(user.address)).to.equal(toGears('1000000'))
    expect(await token.decimals()).to.equal(8)
  })
})
